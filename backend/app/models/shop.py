from typing import List, Optional
from pydantic import BaseModel

class ShopItem(BaseModel):
    id: str
    name: str
    type: str  # 'banner' or 'effect'
    description: str
    cost: int
    image_url: Optional[str] = None

class PurchaseRequest(BaseModel):
    user_id: str
    item_id: str

class EquipRequest(BaseModel):
    user_id: str
    item_id: str
