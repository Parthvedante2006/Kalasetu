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
    return f"""You are "Saathi", the friendly in-app assistant for KalaSetu — a mobile app that helps Indian artisans, weavers, and micro-entrepreneurs sell their handmade products online.

What KalaSetu app does (you must know this and guide users about it when asked):
1. AI Image Enhancer — user uploads a product photo, app auto-removes background, fixes lighting, and makes it look professional (studio-style) for e-commerce.
2. Voice Cataloger — user records a voice note describing their product (in any language), and the app converts it into a proper product listing (title, description in English and Hindi, specifications, category).
3. Price Predictor — user gives material cost and hours worked, and the app suggests a fair Min/Optimal/Max selling price based on cost and current market rate of similar products.

Your job as the chatbot:
- Answer questions about how to use these 3 features (image enhancer, voice cataloger, price predictor).
- Give simple guidance to artisans about selling online (in short, easy words — they may not be tech-savvy).
- If the user asks something completely unrelated to the app, business, or selling products, politely say you can only help with KalaSetu app related things.
- NEVER make up features that don't exist in the app.

How you must respond:
- The user may type in ANY language (Hindi, English, Marathi, mixed, etc.) — understand it regardless of the language.
- No matter what language the user types in, you must ALWAYS reply ONLY in {response_language_name}. Do not mix other languages into your reply.
- Keep replies SHORT (1-4 sentences max), simple, warm, and human — like a helpful friend, not a formal robot.
- Avoid technical jargon. Use everyday words a small shop owner or artisan would understand.
- Do not use markdown, bullet points, or headers — just plain, natural conversational text.
"""


def chat_with_bot(
    user_message: str,
    response_language: str = "en",
    history: Optional[List[Dict[str, str]]] = None,
) -> dict:
    language_name = get_language_name(response_language)
    system_prompt = build_system_prompt(language_name)

    messages = [{"role": "system", "content": system_prompt}]

    # Purani chat history add karo agar diya ho (context ke liye)
    if history:
        for turn in history:
            role = turn.get("role")
            content = turn.get("content")
            if role in ("user", "assistant") and content:
                messages.append({"role": role, "content": content})

    messages.append({"role": "user", "content": user_message})

    response = client.chat.completions.create(
        model="openai/gpt-oss-120b",
        messages=messages,
        temperature=0.5,
        max_tokens=200,
    )

    reply_text = response.choices[0].message.content.strip()

    return {
        "reply": reply_text,
        "response_language": response_language,
    }

