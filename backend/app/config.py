import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    DATABASE_NAME = os.getenv("DATABASE_NAME", "ai_tutor_db")
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

    @property
    def API_BASE_URL(self):
        # Default for Android Emulator to see Laptop's localhost
        return "10.0.2.2:8000"

    @property
    def WS_PROTOCOL(self):
        return "ws"

config = Config()
