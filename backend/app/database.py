from motor.motor_asyncio import AsyncIOMotorClient
from app.config import config

class Database:
    client: AsyncIOMotorClient = None

    def connect_to_database(self):
        # tlsAllowInvalidCertificates=True allows connecting even if system date is incorrect
        self.client = AsyncIOMotorClient(config.MONGODB_URL, tlsAllowInvalidCertificates=True)
        print("Connected to MongoDB")

    def close_database_connection(self):
        if self.client:
            self.client.close()
            print("Closed MongoDB connection")

    def get_db(self):
        return self.client[config.DATABASE_NAME]
    
    # Collection properties
    @property
    def users(self):
        return self.get_db()["users"]
    
    @property
    def chats(self):
        return self.get_db()["chats"]
    
    @property
    def user_gamifications(self):
        return self.get_db()["user_gamifications"]
    
    @property
    def leaderboards(self):
        return self.get_db()["leaderboards"]

db = Database()
