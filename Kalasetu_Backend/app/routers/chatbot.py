from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, List, Dict
from app.services.chatbot_service import chat_with_bot

router = APIRouter(prefix="/chatbot", tags=["Chatbot"])


class ChatRequest(BaseModel):
    message: str
    response_language: Optional[str] = "en"   # dropdown se aayega: "en", "hi", "mr", etc.
    history: Optional[List[Dict[str, str]]] = None  # [{"role": "user"/"assistant", "content": "..."}]


@router.post("/chat")
async def chat_endpoint(payload: ChatRequest):
    result = chat_with_bot(
        user_message=payload.message,
        response_language=payload.response_language,
        history=payload.history,
    )
    return result


