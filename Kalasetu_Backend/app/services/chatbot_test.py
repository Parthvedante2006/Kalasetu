from app.services.chatbot_service import chat_with_bot

if __name__ == "__main__":
    # --- Test 1: User Hindi mein poochta hai, response English mein chahiye ---
    print("--- Test 1: Hindi input, English output ---")
    result1 = chat_with_bot(
        user_message="Mera photo kaise achha dikhega app mein?",
        response_language="en",
    )
    print(result1)
    print()

    # --- Test 2: User English mein poochta hai, response Hindi mein chahiye ---
    print("--- Test 2: English input, Hindi output ---")
    result2 = chat_with_bot(
        user_message="How do I find out the right price for my product?",
        response_language="hi",
    )
    print(result2)
    print()

    # --- Test 3: With chat history (context wala test) ---
    print("--- Test 3: With history ---")
    history = [
        {"role": "user", "content": "Mujhe voice se catalog banana hai"},
        {"role": "assistant", "content": "Bilkul, app mein voice note record karke bol dijiye product ke baare mein."},
    ]
    result3 = chat_with_bot(
        user_message="Kaunsi language mein bol sakta hu?",
        response_language="hi",
        history=history,
    )
    print(result3)
    print()

    # --- Test 4: Unrelated question (out of scope check) ---
    print("--- Test 4: Unrelated question ---")
    result4 = chat_with_bot(
        user_message="Aaj cricket match kaun jeeta?",
        response_language="en",
    )
    print(result4)



    