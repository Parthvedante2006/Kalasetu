from app.services.price_predictor import predict_price

if __name__ == "__main__":
    sample_input = {
        "transcribed_text":  "Yeh clay ka pot hai handmade",
        "material_cost": 300,
        "hours": 4,
        "category": "pottery",
    }

    result = predict_price(**sample_input)
    print(result)



