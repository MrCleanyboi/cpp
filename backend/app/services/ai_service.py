import google.generativeai as genai
from app.config import config

class AIService:
    def __init__(self):
        if config.GEMINI_API_KEY:
            genai.configure(api_key=config.GEMINI_API_KEY)
            self.model = genai.GenerativeModel('gemini-pro')
        else:
            print("Warning: Gemini API Key not found. AI features will not work.")
            self.model = None

    async def get_response(self, user_message: str, target_language: str = "Spanish") -> dict:
        if not self.model:
             return {
                "reply": "AI Configuration Error: API Key missing.",
                "correction": "N/A"
            }
        
        # Prompt engineering for language tutor
        prompt = f"""
        You are an helpful AI Language Tutor. The user is learning {target_language}.
        The user says: "{user_message}"
        
        1. Reply naturally in {target_language} to keep the conversation going.
        2. Check for any grammatical errors in the user's message.
        
        Format your response as valid JSON with two fields: 'reply' and 'correction'.
        If there are no errors, 'correction' should be "No errors found." or a positive reinforcement.
        """
        
        try:
            response = self.model.generate_content(prompt)
            # Simple clean up to ensure we get json-like text if the model is chatty
            text = response.text.replace("```json", "").replace("```", "").strip()
            import json
            return json.loads(text)
        except Exception as e:
            print(f"Error generating AI response: {e}")
            # Fallback for demo/invalid key
            return {
                "reply": "I am having trouble connecting to my brain (API Key Error). But I can still chat! (Simulated)",
                "correction": "No grammar checks available in offline mode."
            }

ai_service = AIService()
