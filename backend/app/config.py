import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    DATABASE_NAME = os.getenv("DATABASE_NAME", "ai_tutor_db")
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
    
    # FOR NGROK: Set this to your ngrok host, e.g., "lexico-123.ngrok-free.app"
    # Leave empty for local development
    NGROK_HOST = os.getenv("NGROK_HOST")
    
    @property
    def API_BASE_URL(self):
        if self.NGROK_HOST:
            return self.NGROK_HOST
        return "10.0.2.2:8000" # Default for Android Emulator to see Laptop

    @property
    def WS_PROTOCOL(self):
        return "wss" if self.NGROK_HOST else "ws"

config = Config()
