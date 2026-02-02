import os
import whisper

# Load model ONCE (important for performance)
model = whisper.load_model("base")

def transcribe_audio(audio_path: str) -> dict:
    """
    Transcribes a .wav audio file into text using Whisper.
    Returns dictionary with text and words.
    """

    # Safety check
    if not os.path.exists(audio_path):
        raise FileNotFoundError(f"Audio file not found: {audio_path}")
    
    file_size = os.path.getsize(audio_path)
    print(f"DEBUG: Transcribing file: {audio_path} (Size: {file_size} bytes)")


    # Whisper expects a file path (ffmpeg handles decoding)
    result = model.transcribe(
        audio_path,
        language="es",          # Spanish (change later if needed)
        fp16=False,             # REQUIRED on Windows / CPU
        word_timestamps=True    # Required for pause analysis
    )

    words = []
    for segment in result.get("segments", []):
        for word in segment.get("words", []):
            words.append({
                "word": word["word"].strip(),
                "start": word["start"],
                "end": word["end"]
            })

    return {
        "text": result["text"].strip(),
        "words": words
    }
