import asyncio
import httpx

async def test_backend():
    async with httpx.AsyncClient() as client:
        # Test Root
        try:
            resp = await client.get("http://localhost:8000/")
            print("Root Response:", resp.json())
        except Exception as e:
            print("Root Test Failed:", e)

        # Test Chat (Mock if no API key)
        try:
            resp = await client.post("http://localhost:8000/chat", json={"message": "Hello", "target_language": "Spanish"})
            print("Chat Response:", resp.json())
        except Exception as e:
            print("Chat Test Failed:", e)

if __name__ == "__main__":
    asyncio.run(test_backend())
