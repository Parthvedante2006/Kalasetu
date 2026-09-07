import json
import os
import re
from typing import Optional
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from groq import Groq
from app.core.config import GROQ_API_KEY

client = Groq(api_key=GROQ_API_KEY)

DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "sample_products.json")
DEFAULT_HOURLY_RATE = 150  # ₹ per hour, fallback


def load_sample_products() -> list:
    with open(DATA_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


# --- Checker #1: cost info validation (on voice-transcribed text) ---
def check_cost_details_present(transcribed_text: str) -> dict:
    text = transcribed_text.lower()
    has_number = bool(re.search(r"\d+", text))
    has_cost_word = bool(re.search(r"rupee|rs\.?|kharcha|cost|price|lagat|material", text))
    has_hour_word = bool(re.search(r"ghanta|ghante|hour|hours|time", text))

    missing = []
    if not (has_number and has_cost_word):
        missing.append("material_cost")
    if not (has_number and has_hour_word):
        missing.append("hours_worked")

    return {"is_complete": len(missing) == 0, "missing_fields": missing}


# --- Static rule: Base Cost ---
def calculate_base_cost(material_cost: float, hours: float, hourly_rate: float = DEFAULT_HOURLY_RATE) -> float:
    return round(material_cost + (hours * hourly_rate), 2)


# --- Checker #2: similarity-based market rate ---
def find_similar_products(description: str, category: Optional[str] = None, top_n: int = 3) -> list:
    products = load_sample_products()
    if category:
        filtered = [p for p in products if p["category"].lower() == category.lower()]
        products = filtered if filtered else products

    corpus = [p["description"] for p in products] + [description]
    vectorizer = TfidfVectorizer()
    tfidf = vectorizer.fit_transform(corpus)

    sims = cosine_similarity(tfidf[-1], tfidf[:-1]).flatten()
    ranked = sorted(zip(products, sims), key=lambda x: x[1], reverse=True)

    return [p for p, score in ranked[:top_n]]


def get_market_rate(similar_products: list) -> float:
    if not similar_products:
        return 0.0
    prices = [p["market_price"] for p in similar_products]
    return round(sum(prices) / len(prices), 2)


# --- LLM cross-check + justification ---
def justify_price_with_llm(base_cost: float, market_rate: float, similar_products: list, description: str) -> dict:
    similar_text = "\n".join(
        f"- {p['description']} (₹{p['market_price']})" for p in similar_products
    ) or "No close matches found."

    prompt = f"""You are a pricing advisor for Indian artisans selling on e-commerce.

Product description: "{description}"

Base Cost (material + labor, calculated): ₹{base_cost}
Market Rate (average of similar products found): ₹{market_rate}

Similar products found:
{similar_text}

Based on these two numbers, suggest a final price range and give short, simple, practical advice for the artisan (in easy language, no jargon).

Respond ONLY in this exact JSON format, no markdown fences:
{{
  "min_price": <number>,
  "optimal_price": <number>,
  "max_price": <number>,
  "advice": "short simple 1-2 sentence advice"
}}"""

    response = client.chat.completions.create(
        model="openai/gpt-oss-120b",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )

    raw = response.choices[0].message.content.strip()
    raw = raw.replace("```json", "").replace("```", "").strip()

    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        start = raw.find("{")
        end = raw.rfind("}") + 1
        return json.loads(raw[start:end])


# --- Orchestrator ---
def predict_price(
    transcribed_text: str,
    description: str,
    material_cost: float,
    hours: float,
    category: Optional[str] = None,
    hourly_rate: float = DEFAULT_HOURLY_RATE,
) -> dict:
    check = check_cost_details_present(transcribed_text)
    if not check["is_complete"]:
        return {
            "status": "incomplete",
            "missing_fields": check["missing_fields"],
            "message": "Kripya material cost aur time (hours) bataiye price predict karne ke liye.",
        }

    base_cost = calculate_base_cost(material_cost, hours, hourly_rate)
    similar_products = find_similar_products(description, category)
    market_rate = get_market_rate(similar_products)

    justification = justify_price_with_llm(base_cost, market_rate, similar_products, description)

    return {
        "status": "success",
        "base_cost": base_cost,
        "market_rate": market_rate,
        "similar_products": similar_products,
        **justification,
    }


