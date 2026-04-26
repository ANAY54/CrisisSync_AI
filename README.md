# CrisisSync AI 🚨
Real-time emergency response platform powered by Google Gemini AI, Firebase, and Flutter.

Built for Google Solution Challenge 2026 — Theme: Rapid Crisis Response

## Setup

### Backend
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env        # Add your Gemini API key
uvicorn main:app --reload

### Flutter
cd mobile/crisis_sync_app
flutter pub get
flutter run

## Tech Stack
- Google Gemini 2.5 Flash (AI Engine)
- Flutter + Dart (Mobile App)
- Firebase Firestore (Real-time Database)
- FastAPI + Python (Backend)