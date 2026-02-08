import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
import certifi

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
print(f"Testing connection to: {MONGODB_URL.split('@')[1] if '@' in MONGODB_URL else 'LOCALHOST'}...")

async def test_connection():
    try:
        # Added tlsCAFile for SSL certificate issues which are common on Windows
        client = AsyncIOMotorClient(MONGODB_URL, tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)
        print("Client created...")
        # Force a connection verification
        await client.admin.command('ping')
        print("Result: SUCCESS - Connected to MongoDB!")
    except Exception as e:
        print(f"Result: FAILED - {type(e).__name__}: {e}")

if __name__ == "__main__":
    asyncio.run(test_connection())
