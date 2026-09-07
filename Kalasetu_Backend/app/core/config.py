import os
from dotenv import load_dotenv

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
SUPABASE_JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")

# Directory where enhanced product images are saved on the laptop
STORAGE_DIR = os.path.join(os.path.dirname(__file__), "..", "storage", "images")
os.makedirs(STORAGE_DIR, exist_ok=True)

# Max upload size accepted from the phone (bytes)
MAX_UPLOAD_BYTES = 20 * 1024 * 1024  # 20 MB