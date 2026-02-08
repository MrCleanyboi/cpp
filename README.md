# AI Language Tutor - Setup & Run

## Prerequisites
1. **Flutter SDK** installed and in your PATH.
2. **Python 3.10+** installed.
3. **Android Studio** (for Emulator) or a physical Android device.

## 1. Setup Backend (The Brain)
The app needs the backend to answer chat messages.

1. Open a terminal in `ai_language_tutor/backend`.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the server:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```
   *Keep this terminal open.*

## 2. Setup Frontend (The App)
1. Open a *new* terminal in `ai_language_tutor/frontend`.
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Note for Android Emulator
The app is configured to connect to `http://10.0.2.2:8000`, which is the special IP address for "localhost" inside the Android Emulator.
- If running on a **Physical Device**, you must change `baseUrl` in `lib/services/api_service.dart` to your computer's local Wi-Fi IP (e.g., `192.168.1.X:8000`).
