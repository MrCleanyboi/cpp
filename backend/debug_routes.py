
from app.main import app
from fastapi.routing import APIRoute, APIWebSocketRoute

print("Registered Routes:")
for route in app.routes:
    if isinstance(route, APIRoute):
        print(f"HTTP: {route.path} [{','.join(route.methods)}]")
    elif isinstance(route, APIWebSocketRoute):
        print(f"WS:   {route.path}")
    else:
        print(f"Other: {route.path}")
