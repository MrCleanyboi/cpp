from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import List, Dict

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        # Store active connections: user_id -> WebSocket
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        print(f"DEBUG: WebSocket connected for user {user_id}. Total connections: {len(self.active_connections)}")
        print(f"User {user_id} connected via WebSocket")

    def disconnect(self, user_id: str):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
            print(f"User {user_id} disconnected")

    async def send_personal_message(self, message: dict, user_id: str):
        print(f"DEBUG: Attempting to send message to user {user_id}. Active: {list(self.active_connections.keys())}")
        if user_id in self.active_connections:
            print(f"DEBUG: Sending message to {user_id}: {message}")
            await self.active_connections[user_id].send_json(message)
        else:
            print(f"DEBUG: User {user_id} not connected, message not sent")

    async def broadcast(self, message: dict):
        for connection in self.active_connections.values():
            await connection.send_json(message)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            # simple echo for now, or routing logic later
            await manager.send_personal_message({"type": "echo", "text": f"You wrote: {data}"}, user_id)
    except WebSocketDisconnect:
        manager.disconnect(user_id)
