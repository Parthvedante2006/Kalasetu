from fastapi import APIRouter, UploadFile, File
from fastapi.responses import StreamingResponse
from app.services.image_enhancer import enhance_product_image
import io

router = APIRouter(prefix="/image", tags=["Image Enhancer"])


@router.post("/enhance")
async def enhance_image(file: UploadFile = File(...)):
    contents = await file.read()
    final_img = enhance_product_image(contents)

    output = io.BytesIO()
    final_img.save(output, format="JPEG", quality=92)
    output.seek(0)
    return StreamingResponse(output, media_type="image/jpeg")