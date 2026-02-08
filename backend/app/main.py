from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.database import db

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    db.connect_to_database()
    yield
    # Shutdown
    db.close_database_connection()

app = FastAPI(title="AI Language Tutor Backend", lifespan=lifespan)

from fastapi.middleware.cors import CORSMiddleware

# Allow CORS for all origins (or specify your flutter web port)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"status": "AI Tutor Backend Running", "db_status": "Connected" if db.client else "Disconnected"}

from app.routes import chat, websocket, gamification, auth, ai_tutor
app.include_router(chat.router)
app.include_router(websocket.router)
app.include_router(gamification.router)
app.include_router(auth.router)
app.include_router(ai_tutor.router)

