from transformers import pipeline

# Load model once at startup (CPU mode)
generator = pipeline(
    "text2text-generation",
    model="google/flan-t5-small",
    device=-1
)

# Language-specific starter phrases used in fallbacks
_FALLBACK_GREETINGS = {
    "German": ("Hallo", "Hello"),
    "French": ("Bonjour", "Hello"),
    "Spanish": ("Hola", "Hello"),
}

# Banned phrases that indicate the model misbehaved
_BANNED_PREFIXES = ["no,", "no ", "thank you", "thanks"]


def _fallback(target_language: str) -> str:
    """Return a safe, language-specific greeting when the AI fails."""
    native, english = _FALLBACK_GREETINGS.get(
        target_language, ("Hello", "Hello")
    )
    return (
        f"Let's start learning {target_language}! "
        f"The word for '{english}' in {target_language} is '{native}'. "
        f"Try saying: {native}!"
    )


def generate_response(conversation, target_language: str = "German") -> str:
    user_message = conversation[-1]["content"].strip()

    # Build a translation prompt that explicitly names the target language
    prompt = f"translate English to {target_language}: {user_message}"
    print(f"DEBUG: sending prompt to LLM: {prompt}")

    try:
        result = generator(
            prompt,
            max_new_tokens=80,
            do_sample=False,
            num_beams=5,
            repetition_penalty=2.0,
            no_repeat_ngram_size=3,
            early_stopping=True,
        )

        reply = result[0]["generated_text"].strip()
        print(f"DEBUG: Raw LLM generation: '{reply}'")

        # Safety check: reject nonsensical outputs
        if not reply or any(reply.lower().startswith(b) for b in _BANNED_PREFIXES):
            print("DEBUG: Triggered fallback (banned/empty reply)")
            return _fallback(target_language)

        return reply

    except Exception as e:
        print(f"DEBUG: LLM Generation Error: {e}")
        return _fallback(target_language)
