import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

# Load environment variables
load_dotenv()

async def reset_matches():
    mongodb_url = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    database_name = os.getenv("DATABASE_NAME", "ai_tutor_db")
    
    print(f"Connecting to {database_name}...")
    client = AsyncIOMotorClient(mongodb_url)
    db = client[database_name]
    
    # 1. Clear Waiting Queue
    print("🧹 Clearing Waiting Queue...")
    result_q = await db.waiting_queue.delete_many({})
    print(f"   - Removed {result_q.deleted_count} users from queue")

    # 2. Clear Active Matches
    print("🧹 Clearing Active Matches...")
    result_m = await db.active_matches.delete_many({})
    print(f"   - Removed {result_m.deleted_count} active matches")
    
    # 3. Optional: Clear session/call states if any
    # print("🧹 Clearing Call states...")
    # await db.calls.delete_many({})

    print("\n✅ All matches and queues have been reset!")

if __name__ == "__main__":
    asyncio.run(reset_matches())
