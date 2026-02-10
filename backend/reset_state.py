import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("DATABASE_NAME", "ai_tutor_db")

async def reset_state():
    print(f"Connecting to {DATABASE_NAME}...")
    client = AsyncIOMotorClient(MONGODB_URL, tlsAllowInvalidCertificates=True)
    db = client[DATABASE_NAME]
    
    # 1. Clear Waiting Queue
    print("🧹 Clearing Waiting Queue...")
    result_q = await db.waiting_queue.delete_many({})
    print(f"   - Removed {result_q.deleted_count} users from queue")

    # 2. Clear Active Matches
    print("🧹 Clearing Active Matches...")
    result_m = await db.active_matches.delete_many({})
    print(f"   - Removed {result_m.deleted_count} active matches")
    
    print("\n✅ System matches reset! You can now try matching your two devices.")

if __name__ == "__main__":
    asyncio.run(reset_state())
