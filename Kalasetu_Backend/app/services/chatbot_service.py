import json
from typing import Optional, List, Dict
from groq import Groq
from app.core.config import GROQ_API_KEY

client = Groq(api_key=GROQ_API_KEY)

# Language code -> full name (LLM ko clearly batane ke liye)
LANGUAGE_MAP = {
    "en": "English",
    "hi": "Hindi",
    "mr": "Marathi",
    "gu": "Gujarati",
    "ta": "Tamil",
    "te": "Telugu",
    "bn": "Bengali",
    "pa": "Punjabi",
    "kn": "Kannada",
}


def get_language_name(code: str) -> str:
    return LANGUAGE_MAP.get(code.lower().strip(), "English")


# --- System prompt: app-aware, short, human, simple ---
def build_system_prompt(response_language_name: str) -> str:
    return f"""You are "Saathi", the friendly AI assistant for KalaSetu — a mobile app empowering Indian artisans, weavers, and micro-entrepreneurs to sell their handcrafted products online.

KalaSetu Core Features (guide users on these when asked):
1. AI Image Enhancer: Automatically removes backgrounds, optimizes studio lighting, and generates high-converting e-commerce product photos.
2. Voice Cataloger: Artisans record voice descriptions in any regional language, auto-generating structured listings (title, English/Hindi descriptions, specs, category).
3. Price Predictor: Calculates optimal Min/Optimal/Max pricing based on material cost, craftsmanship hours, and real-time market data.
4. Multichannel Publishing: Sell retail on Amazon or send bulk wholesale proposals to verified B2B buyers.

Your Instructions:
- Understand user queries in any Indian regional language or English.
- Always respond exclusively in {response_language_name}.
- Structure your response cleanly: use short paragraphs, clear bullet points (`*` or `-`), bold key terms (`**term**`), or numbered lists where appropriate for readability.
- Be concise, direct, supportive, and practical for artisans and small business owners.
- If asked about unrelated non-craft/non-business topics, politely redirect back to KalaSetu and craft business guidance.
"""


def chat_with_bot(
    user_message: str,
    response_language: str = "en",
    history: Optional[List[Dict[str, str]]] = None,
) -> dict:
    language_name = get_language_name(response_language)
    system_prompt = build_system_prompt(language_name)

    messages = [{"role": "system", "content": system_prompt}]

    if history:
        for turn in history:
            role = turn.get("role")
            content = turn.get("content")
            if role in ("user", "assistant") and content:
                messages.append({"role": role, "content": content})

    messages.append({"role": "user", "content": user_message})

    try:
        response = client.chat.completions.create(
            model="openai/gpt-oss-120b",
            messages=messages,
            temperature=0.5,
            max_tokens=350,
        )

        reply_text = response.choices[0].message.content.strip()

        return {
            "reply": reply_text,
            "response_language": response_language,
            "is_error": False,
        }
    except Exception as e:
        return {
            "reply": f"Backend Error: Unable to process request with AI model ({str(e)})",
            "response_language": response_language,
            "is_error": True,
        }

