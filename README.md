# Lexico - AI Language Tutor

Lexico is a polished AI-powered language learning application built with Flutter and FastAPI.

## Prerequisites
1. **Flutter SDK** (>= 3.0.0)
2. **Python** (3.10+)
3. **MongoDB** (running locally or via Atlas)
4. **Gemini API Key** (from Google AI Studio)

---

## 🚀 Setup Instructions

### 1. Backend Configuration
1. Navigate to the `backend/` directory.
2. Create a `.env` file by copying the template:
   ```bash
   cp .env.example .env
   ```
3. Open `.env` and fill in your:
   - `MONGODB_URL`
   - `GEMINI_API_KEY`
4. Create a virtual environment and install dependencies:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```
5. Seed the database with initial course data:
   ```bash
   python seed_courses.py
   ```
6. Run the server:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

### 2. Frontend Configuration
1. Navigate to the `frontend/` directory.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   - **Android Emulator**: Run `flutter run` (Connects to `10.0.2.2`).
   - **Chrome/Web**: Run `flutter run -d chrome` (Connects to `localhost`).
   - **Desktop**: Run `flutter run` (Connects to `127.0.0.1`).

## 🛠 Features
- **Learning Path:** Curated lessons with interactive exercises.
- **AI Tutor:** Real-time chat practice with an AI persona.
- **Connect:** Match with partners and practice via text or WebRTC (experimental).
- **Gamification:** Earn gems, track hearts, and unlock achievements.

## 📝 License
This project is for educational purposes.
