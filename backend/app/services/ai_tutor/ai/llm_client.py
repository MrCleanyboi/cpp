from transformers import pipeline

# Load model once
generator = pipeline(
    "text2text-generation",
    model="google/flan-t5-small",
    device=-1  # CPU
)

SYSTEM_PROMPT = (
    "You are an AI Spanish tutor for beginners.\n"
    "You NEVER refuse.\n"
    "You NEVER say no.\n"
    "You NEVER thank the user.\n"
    "You ALWAYS start teaching immediately.\n"
    "Your answer must contain a Spanish word and its English meaning.\n"
    "Keep responses short and encouraging."
)

def generate_response(conversation):
    user_message = conversation[-1]["content"].strip()

    # Use T5's native translation task prefix which is much more reliable
    prompt = f"translate English to Spanish: {user_message}"
    print(f"DEBUG: sending prompt to LLM: {prompt}")

    try:
        result = generator(
            prompt,
            max_new_tokens=80,
            do_sample=False,
            num_beams=5,
            repetition_penalty=2.0,
            no_repeat_ngram_size=3,
            early_stopping=True
        )

        reply = result[0]["generated_text"].strip()
        print(f"DEBUG: Raw LLM generation: '{reply}'")

        # 🚨 HARD SAFETY FALLBACK (IMPORTANT)
        banned_phrases = ["no,", "no ", "thank you", "thanks"]
        if any(reply.lower().startswith(b) for b in banned_phrases):
            print("DEBUG: Triggered banned phrase fallback")
            return (
                "Let’s start learning Spanish! "
                "The word for 'Hello' in Spanish is 'Hola'. "
                "Try saying: Hola!"
            )

        # Relaxed check: Just ensure it's not empty
        if not reply:
             print("DEBUG: Empty reply fallback")
             return "Hola! I am ready to help. Say 'Hola' to start."

        return reply

    except Exception as e:
        print(f"DEBUG: LLM Generation Error: {e}")
        return (
            "Let’s start learning Spanish! "
            "The word for 'Hello' in Spanish is 'Hola'. "
            "Try saying: Hola!"
        )
