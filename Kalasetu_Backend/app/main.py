from fastapi import FastAPI
from app.routers import image, voice, price

app = FastAPI(title="Kalasetu Backend")

app.include_router(image.router)
app.include_router(voice.router)
app.include_router(price.router)


@app.get("/")
def health_check():
    return {"status": "Kalasetu backend is running"}