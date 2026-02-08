from fastapi import APIRouter, UploadFile, File
import tempfile

from app.models.ai_tutor import ChatRequest, ChatResponse
from app.services.ai_tutor.core.dialogue_manager import DialogueManager
from app.services.ai_tutor.speech.transcriber import transcribe_audio
from app.services.ai_tutor.speech.pause_analyzer import analyze_pauses

router = APIRouter(prefix="/ai-tutor", tags=["AI Tutor"])
dialogue_manager = DialogueManager()

@router.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    reply = dialogue_manager.handle_message(request.message)
    return ChatResponse(reply=reply)

@router.post("/speech")
async def speech_input(audio: UploadFile = File(...)):
    print(f"DEBUG: Received audio file: {audio.filename}")
    # Save temp file
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp.write(await audio.read())
        audio_path = tmp.name

    transcription = transcribe_audio(audio_path)
    print(f"DEBUG: Transcribed text: '{transcription['text']}'")
    pause_info = analyze_pauses(transcription["words"])

    # Send structured data to tutor
    reply = dialogue_manager.handle_message(
        transcription["text"],
        metadata=pause_info
    )

    return {
        "text": transcription["text"],
        "pause_analysis": pause_info,
        "reply": reply
    }
