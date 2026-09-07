from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from app.services.price_predictor import predict_price

router = APIRouter(prefix="/price", tags=["Price Predictor"])


class PriceRequest(BaseModel):
    transcribed_text: str
    description: str
    material_cost: float
    hours: float
    category: Optional[str] = None


@router.post("/predict")
async def predict_price_endpoint(payload: PriceRequest):
    result = predict_price(
        transcribed_text=payload.transcribed_text,
        description=payload.description,
        material_cost=payload.material_cost,
        hours=payload.hours,
        category=payload.category,
    )
    return result


