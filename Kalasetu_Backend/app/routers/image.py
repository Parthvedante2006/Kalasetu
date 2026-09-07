import io
import os
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import FileResponse, StreamingResponse

from app.core.auth import verify_user
from app.core.config import MAX_UPLOAD_BYTES, STORAGE_DIR
from app.services.image_enhancer import enhance_product_image

router = APIRouter(prefix="/image", tags=["Image Enhancer"])


@router.post("/enhance")
async def enhance_image(
    file: UploadFile = File(...),
    user_id: str = Depends(verify_user),
):
    contents = await file.read()

    if len(contents) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail="Image too large (max 20 MB)")

    final_img = enhance_product_image(contents)

    # Save to per-user folder
    user_dir = os.path.join(STORAGE_DIR, user_id)
    os.makedirs(user_dir, exist_ok=True)
    filename = f"{uuid.uuid4().hex}.jpg"
    save_path = os.path.join(user_dir, filename)
    final_img.save(save_path, format="JPEG", quality=92)

    return {"image_path": f"{user_id}/{filename}"}


@router.get("/view/{user_id}/{filename}")
async def view_image(
    user_id: str,
    filename: str,
    requester_id: str = Depends(verify_user),
):
    if requester_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized to view this image")

    filepath = os.path.join(STORAGE_DIR, user_id, filename)
    if not os.path.exists(filepath):
        raise HTTPException(status_code=404, detail="Image not found")

    return FileResponse(filepath, media_type="image/jpeg")