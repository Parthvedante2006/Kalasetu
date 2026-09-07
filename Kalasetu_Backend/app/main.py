from fastapi import FastAPI
from app.routers import image

app = FastAPI(title="Kalasetu Backend")

app.include_router(image.router)


@app.get("/")
def health_check():
    return {"status": "Kalasetu backend is running"}