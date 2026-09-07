import cv2
import numpy as np
from rembg import remove, new_session
from PIL import Image, ImageFilter, ImageDraw
import colorsys
import io

session = new_session("isnet-general-use")


def auto_correct_lighting(image: np.ndarray) -> np.ndarray:
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)

    # Measure current brightness (mean L channel, 0-255 scale)
    mean_brightness = np.mean(l)

    # If already well-exposed, skip CLAHE entirely — don't fix what isn't broken
    if 100 <= mean_brightness <= 180:
        return image  # good lighting already, leave it alone

    # Decide correction strength based on how far off it is
    if mean_brightness < 100:
        # underexposed — apply CLAHE to bring up shadows/midtones
        clip_limit = 2.0
        l = cv2.createCLAHE(clipLimit=clip_limit, tileGridSize=(8, 8)).apply(l)
        # gentle brightness boost proportional to how dark it is
        gain = min(1.4, 120 / max(mean_brightness, 1))
        l = np.clip(l.astype(np.float32) * gain, 0, 255).astype(np.uint8)
    else:
        # overexposed — mild contrast correction only, don't darken aggressively
        clip_limit = 1.2
        l = cv2.createCLAHE(clipLimit=clip_limit, tileGridSize=(8, 8)).apply(l)

    corrected = cv2.merge((l, a, b))
    corrected = cv2.cvtColor(corrected, cv2.COLOR_LAB2BGR)

    try:
        result = cv2.xphoto.createSimpleWB().balanceWhite(corrected)
    except AttributeError:
        result = corrected

    return result


def remove_background(image_bytes: bytes) -> Image.Image:
    output_bytes = remove(image_bytes, session=session)
    return Image.open(io.BytesIO(output_bytes)).convert("RGBA")


def straighten_product(product_img: Image.Image) -> Image.Image:
    arr = np.array(product_img)
    alpha = arr[:, :, 3]
    coords = np.column_stack(np.where(alpha > 200))
    if len(coords) < 10:
        return product_img
    rect = cv2.minAreaRect(coords.astype(np.float32))
    angle = rect[-1]
    if angle < -45:
        angle = 90 + angle
    if 0.5 < abs(angle) < 20:
        product_img = product_img.rotate(-angle, expand=True, resample=Image.BICUBIC)
    return product_img


def get_dominant_color(product_img: Image.Image) -> tuple:
    arr = np.array(product_img)
    mask = arr[:, :, 3] > 200
    pixels = arr[mask][:, :3]
    if len(pixels) == 0:
        return (200, 200, 200)
    return tuple(pixels.mean(axis=0).astype(int))


def pick_backdrop_color(product_color: tuple) -> tuple:
    r, g, b = [c / 255 for c in product_color]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    backdrop_h = (h + 0.5) % 1.0
    backdrop_l = 0.75 if l > 0.6 else 0.92
    backdrop_s = 0.06
    r2, g2, b2 = colorsys.hls_to_rgb(backdrop_h, backdrop_l, backdrop_s)
    return (int(r2 * 255), int(g2 * 255), int(b2 * 255))


def add_reflection(backdrop: Image.Image, product_img: Image.Image, px: int, py: int) -> Image.Image:
    reflection = product_img.transpose(Image.FLIP_TOP_BOTTOM)
    r, g, b, a = reflection.split()
    a = a.point(lambda v: int(v * 0.15))

    fade = Image.new("L", reflection.size, 0)
    fade_draw = ImageDraw.Draw(fade)
    for y in range(reflection.height):
        val = int(255 * (1 - y / reflection.height))
        fade_draw.line([(0, y), (reflection.width, y)], fill=val)

    combined_alpha = Image.composite(a, Image.new("L", a.size, 0), fade)
    reflection.putalpha(combined_alpha)
    backdrop.paste(reflection, (px, py + product_img.height), reflection)
    return backdrop


def add_studio_background(product_img: Image.Image, size=(1000, 1000)) -> Image.Image:
    product_color = get_dominant_color(product_img)
    backdrop_color = pick_backdrop_color(product_color)
    backdrop = Image.new("RGBA", size, backdrop_color + (255,))

    product_img.thumbnail((int(size[0] * 0.6), int(size[1] * 0.6)))
    px = (size[0] - product_img.width) // 2
    py = (size[1] - product_img.height) // 2

    shadow = Image.new("RGBA", size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_w = product_img.width * 0.55
    shadow_h = product_img.height * 0.06
    shadow_cx = px + product_img.width / 2
    shadow_cy = py + product_img.height * 0.98
    shadow_draw.ellipse(
        [shadow_cx - shadow_w / 2, shadow_cy - shadow_h / 2,
         shadow_cx + shadow_w / 2, shadow_cy + shadow_h / 2],
        fill=(0, 0, 0, 60),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(20))
    backdrop = Image.alpha_composite(backdrop, shadow)

    backdrop = add_reflection(backdrop, product_img, px, py)
    backdrop.paste(product_img, (px, py), product_img)
    return backdrop.convert("RGB")


def enhance_product_image(contents: bytes) -> Image.Image:
    np_img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)

    max_dim = 1200
    h, w = np_img.shape[:2]
    if max(h, w) > max_dim:
        scale = max_dim / max(h, w)
        np_img = cv2.resize(np_img, (int(w * scale), int(h * scale)))

    corrected = auto_correct_lighting(np_img)
    _, buf = cv2.imencode(".png", corrected)

    product_img = remove_background(buf.tobytes())
    product_img = straighten_product(product_img)
    final_img = add_studio_background(product_img)
    return final_img