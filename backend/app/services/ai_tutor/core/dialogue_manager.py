from app.services.ai_tutor.core.memory_manager import MemoryManager
from app.services.ai_tutor.ai.llm_client import generate_response

class DialogueManager:
    def __init__(self):
        self.memory = MemoryManager()

    def handle_message(self, text, metadata=None, target_language: str = "German"):
        if metadata:
            if metadata["hesitation"] == "awkward":
                return (
                    "I noticed a long pause. That's okay! "
                    "Let's try saying it slowly together."
                )
            if metadata["hesitation"] == "mild":
                return (
                    "Good effort! Try to speak a bit more smoothly."
                )

        # Normal flow — pass the language through to the LLM
        self.memory.add_user(text)
        reply = generate_response(self.memory.get_conversation(), target_language=target_language)
        self.memory.add_ai(reply)
        return reply
