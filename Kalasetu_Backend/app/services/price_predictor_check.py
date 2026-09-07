from app.services.price_predictor import predict_price

if __name__ == "__main__":
    sample_input = {
        "transcribed_text": "Isme material cost 300 rupees laga aur banane me 4 ghante lage",
        "description": "handmade terracotta clay pot with traditional design",
        "material_cost": 300,
        "hours": 4,
        "category": "pottery",
    }

    result = predict_price(**sample_input)
    print(result)



    