
import asyncio
import websockets
import json

async def test_connection():
    uri = "ws://127.0.0.1:8000/ws/chat/698869672623f58507f07d6e?token=test_token"
    print(f"Connecting to {uri}...")
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected!")
            response = await websocket.recv()
            print(f"Received: {response}")
    except websockets.exceptions.InvalidStatusCode as e:
        print(f"Failed with status code: {e.status_code}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_connection())
