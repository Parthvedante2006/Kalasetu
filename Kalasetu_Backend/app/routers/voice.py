from fastapi import APIRouter, UploadFile, File, Form
from app.services.voice_cataloger import process_voice_to_listing
from typing import Optional

router = APIRouter(prefix="/voice", tags=["Voice Cataloger"])


@router.post("/catalog")
async def catalog_from_voice(
    file: UploadFile = File(...),
    language: Optional[str] = Form(None),  # "hi", "mr", "en" — from artisan's selected app language
):
    contents = await file.read()
    result = process_voice_to_listing(contents, file.filename, language)
    return result