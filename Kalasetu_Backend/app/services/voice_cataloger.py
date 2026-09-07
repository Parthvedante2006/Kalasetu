import json
from groq import Groq
from app.core.config import GROQ_API_KEY

client = Groq(api_key=GROQ_API_KEY)


def transcribe_voice(audio_bytes: bytes, filename: str = "voice.m4a", language: str = None) -> str:
    kwargs = {
        "file": (filename, audio_bytes),
        "model": "whisper-large-v3",
        "response_format": "text",
    }
    if language:
        kwargs["language"] = language  # e.g. "hi", "mr", "en"

    transcription = client.audio.transcriptions.create(**kwargs)
    return transcription


def generate_listing_text(transcribed_text: str) -> dict:
    prompt = f"""You are helping an Indian artisan (or seller) create a professional product listing for an e-commerce marketplace, similar in structure to an Amazon listing.

The seller described their product in their own words (transcribed below, possibly from Hindi, Marathi, or English speech):

"{transcribed_text}"

Do the following:
1. Write a short, catchy product title in English (under 12 words, suitable as a marketplace listing title — include brand/key feature if mentioned).
2. Write a short, SEO-friendly product description in English (2-3 sentences, warm and professional tone).
3. Write the same description translated naturally into Hindi (not literal word-for-word, but natural Hindi as a native speaker would write for a product listing).
4. Extract any specific specifications, features, or measurements mentioned in the description as key-value pairs (e.g. processor, material, dimensions, capacity, color, weight, warranty — only include what was actually mentioned, don't invent values).
5. Identify the product category and primary material (or "not specified" if genuinely not mentioned or not applicable).

Respond ONLY in this exact JSON format, nothing else, no markdown fences:
{{
  "title": "...",
  "description_en": "...",
  "description_hi": "...",
  "specifications": {{
    "key1": "value1",
    "key2": "value2"
  }},
  "category": "...",
  "material": "..."
}}"""

    response = client.chat.completions.create(
    model="openai/gpt-oss-120b",   # was "llama-3.3-70b-versatile"
    messages=[{"role": "user", "content": prompt}],
    temperature=0.4,
)

    raw = response.choices[0].message.content.strip()
    raw = raw.replace("```json", "").replace("```", "").strip()

    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        start = raw.find("{")
        end = raw.rfind("}") + 1
        return json.loads(raw[start:end])


def process_voice_to_listing(audio_bytes: bytes, filename: str, language: str = None) -> dict:
    transcribed = transcribe_voice(audio_bytes, filename, language)
    listing_data = generate_listing_text(transcribed)
    listing_data["transcription"] = transcribed
    return listing_data