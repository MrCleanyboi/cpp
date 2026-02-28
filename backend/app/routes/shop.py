from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models.shop import ShopItem, PurchaseRequest, EquipRequest
from app.database import db
from bson import ObjectId

router = APIRouter(prefix="/api/shop", tags=["shop"])

# In-memory shop items (could be moved to DB later)
SHOP_ITEMS = [
    ShopItem(
        id="banner_neon",
        name="Neon Pulse Banner",
        type="banner",
        description="A vibrant neon banner that pulses with light.",
        cost=100
    ),
    ShopItem(
        id="banner_nature",
        name="Forest Breeze Banner",
        type="banner",
        description="A serene green banner with moving leaf patterns.",
        cost=150
    ),
    ShopItem(
        id="effect_golden",
        name="Golden Aura",
        type="effect",
        description="A prestigious golden glow around your profile photo.",
        cost=200
    ),
    ShopItem(
        id="effect_fire",
        name="Flame Border",
        type="effect",
        description="Dynamic fire effects surrounding your avatar.",
        cost=250
    ),
]

@router.get("/items", response_model=List[ShopItem])
async def get_shop_items():
    return SHOP_ITEMS

@router.post("/purchase")
async def purchase_item(request: PurchaseRequest):
    # Find item
    item = next((i for i in SHOP_ITEMS if i.id == request.item_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    # Get user gamification data
    gamification = await db.user_gamifications.find_one({"user_id": request.user_id})
    if not gamification:
        raise HTTPException(status_code=404, detail="User gamification data not found")

    # Check if already owned
    if request.item_id in gamification.get("inventory", []):
        raise HTTPException(status_code=400, detail="Item already owned")

    # Check gems
    if gamification.get("gems", 0) < item.cost:
        raise HTTPException(status_code=400, detail="Not enough gems")

    # Deduct cost and add to inventory
    await db.user_gamifications.update_one(
        {"user_id": request.user_id},
        {
            "$inc": {"gems": -item.cost},
            "$push": {"inventory": request.item_id}
        }
    )

    return {"message": "Purchase successful", "item_id": request.item_id, "remaining_gems": gamification.get("gems", 0) - item.cost}

@router.post("/equip")
async def equip_item(request: EquipRequest):
    # Find item to verify type
    item = next((i for i in SHOP_ITEMS if i.id == request.item_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    # Get user gamification data
    gamification = await db.user_gamifications.find_one({"user_id": request.user_id})
    if not gamification:
        raise HTTPException(status_code=404, detail="User gamification data not found")

    # Check ownership
    if request.item_id not in gamification.get("inventory", []):
        raise HTTPException(status_code=400, detail="Item not owned")

    # Equip based on type
    update_field = "equipped_banner" if item.type == "banner" else "equipped_effect"
    await db.user_gamifications.update_one(
        {"user_id": request.user_id},
        {"$set": {update_field: request.item_id}}
    )

    return {"message": f"{item.type.capitalize()} equipped successfully", "item_id": request.item_id}
