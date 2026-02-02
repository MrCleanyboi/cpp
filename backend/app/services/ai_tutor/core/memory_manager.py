class MemoryManager:
    def __init__(self):
        self.messages = []

    def add_user(self, text):
        self.messages.append({"role": "user", "content": text})

    def add_ai(self, text):
        self.messages.append({"role": "assistant", "content": text})

    def get_conversation(self):
        return self.messages[-10:]  # short-term memory
