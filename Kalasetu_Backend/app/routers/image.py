from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import StreamingResponse
from app.services.image_enhancer import enhance_product_image
from app.core.config import STORAGE_DIR, MAX_UPLOAD_BYTES
import io
import os
import uuid

router = APIRouter(prefix="/image", tags=["Image Enhancer"])


@router.post("/enhance")
async def enhance_image(file: UploadFile = File(...)):
    contents = await file.read()

    if len(contents) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail="Image too large (max 20 MB)")

    final_img = enhance_product_image(contents)

    # Persist to disk
    image_id = f"{uuid.uuid4().hex}.jpg"
    save_path = os.path.join(STORAGE_DIR, image_id)
    final_img.save(save_path, format="JPEG", quality=92)

    # Stream bytes back to the phone
    output = io.BytesIO()
    final_img.save(output, format="JPEG", quality=92)
    output.seek(0)

    return StreamingResponse(
        output,
        media_type="image/jpeg",
        headers={"X-Image-Id": image_id},
    )