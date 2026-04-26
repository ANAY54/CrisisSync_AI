import json
import os
import time
from datetime import datetime, timezone
from typing import Optional

import firebase_admin
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import credentials, firestore
from pydantic import BaseModel
from google import genai
from google.genai import types

load_dotenv()

app = FastAPI(title="CrisisSync AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------- FIREBASE --------------------
cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# -------------------- GEMINI (new SDK) --------------------
# -------------------- GEMINI --------------------
from dotenv import load_dotenv
load_dotenv()
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

def safe_generate(prompt: str, retries: int = 3) -> str:
    last_error = None
    for attempt in range(retries):
        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
            )
            return response.text.strip()
        except Exception as e:
            last_error = e
            time.sleep(1.5 * (attempt + 1))
    raise HTTPException(status_code=503, detail=f"AI unavailable: {str(last_error)}")

# -------------------- MODELS --------------------
class IncidentRequest(BaseModel):
    description: str
    reporter_name: Optional[str] = "Guest"

class StatusUpdate(BaseModel):
    status: str

class FeedbackRequest(BaseModel):
    incident_id: str
    rating: int
    comment: Optional[str] = ""
    response_adequate: bool = True

# -------------------- HELPERS --------------------
FALLBACK = {
    "type": "Other",
    "severity": "Medium",
    "location": "Unknown",
    "summary": "Incident reported. Manual review required.",
    "suggestions": [
        "Dispatch nearest available staff.",
        "Assess the situation on arrival.",
        "Document findings and report back."
    ]
}

def parse_ai_response(text: str) -> dict:
    text = text.replace("```json", "").replace("```", "").strip()
    try:
        result = json.loads(text)
        if result.get("type") not in ["Fire", "Medical", "Security", "Other"]:
            result["type"] = "Other"
        if result.get("severity") not in ["Low", "Medium", "High"]:
            result["severity"] = "Medium"
        for field in ["type", "severity", "location", "summary", "suggestions"]:
            if field not in result:
                return FALLBACK
        return result
    except Exception:
        return FALLBACK

def analyze_incident(description: str) -> dict:
    prompt = f"""You are an emergency classification AI. Analyze this report and respond with ONLY raw JSON, no markdown, no explanation.

Emergency: "{description}"

Respond with exactly this JSON structure:
{{
  "type": "Fire" or "Medical" or "Security" or "Other",
  "severity": "Low" or "Medium" or "High",
  "location": "short location phrase",
  "summary": "one sentence summary",
  "suggestions": ["action 1", "action 2", "action 3"]
}}"""
    text = safe_generate(prompt)
    return parse_ai_response(text)

def assign_staff(incident_type: str) -> tuple:
    role_map = {"Medical": "Medical", "Fire": "Fire", "Security": "Security", "Other": "Security"}
    needed_role = role_map.get(incident_type, "Security")
    staff_docs = (
        db.collection("staff")
        .where("role", "==", needed_role)
        .where("status", "==", "Available")
        .limit(1)
        .stream()
    )
    for staff_doc in staff_docs:
        data = staff_doc.to_dict()
        db.collection("staff").document(staff_doc.id).update({"status": "Busy"})
        return data.get("name", "Response Team"), staff_doc.id
    return "Response Team", ""

def free_staff(staff_id: str):
    if staff_id:
        db.collection("staff").document(staff_id).update({"status": "Available"})

# -------------------- ROUTES --------------------
@app.get("/")
def health_check():
    return {"status": "CrisisSync AI backend running", "version": "2.0"}

@app.post("/report")
def report_incident(payload: IncidentRequest):
    if not payload.description or len(payload.description.strip()) < 5:
        raise HTTPException(status_code=400, detail="Description too short.")

    ai_result = analyze_incident(payload.description)
    assigned_to, staff_id = assign_staff(ai_result["type"])

    now = datetime.now(timezone.utc)
    incident = {
        "description": payload.description,
        "reporter_name": payload.reporter_name,
        "type": ai_result["type"],
        "severity": ai_result["severity"],
        "location": ai_result["location"],
        "summary": ai_result["summary"],
        "suggestions": ai_result["suggestions"],
        "status": "Assigned",
        "assigned_to": assigned_to,
        "assigned_staff_id": staff_id,
        "created_at": now,
        "updated_at": now,
        "feedback_submitted": False,
        "timeline": [
            {"label": "Reported", "time": now.isoformat()},
            {"label": "AI Classified", "time": now.isoformat()},
            {"label": f"Assigned to {assigned_to}", "time": now.isoformat()},
        ],
    }
    doc_ref = db.collection("incidents").document()
    doc_ref.set(incident)

    return {
        "id": doc_ref.id,
        **incident,
        "created_at": now.isoformat(),
        "updated_at": now.isoformat(),
    }

@app.post("/incident/{incident_id}/status")
def update_incident_status(incident_id: str, payload: StatusUpdate):
    ref = db.collection("incidents").document(incident_id)
    doc = ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Incident not found.")
    now = datetime.now(timezone.utc)
    ref.update({
        "status": payload.status,
        "updated_at": now,
        "timeline": firestore.ArrayUnion([{"label": payload.status, "time": now.isoformat()}])
    })
    if payload.status == "Resolved":
        free_staff(doc.to_dict().get("assigned_staff_id", ""))
    return {"id": incident_id, "status": payload.status}

@app.post("/incident/{incident_id}/feedback")
def submit_feedback(incident_id: str, payload: FeedbackRequest):
    ref = db.collection("incidents").document(incident_id)
    if not ref.get().exists:
        raise HTTPException(status_code=404, detail="Incident not found.")
    now = datetime.now(timezone.utc)
    feedback = {
        "rating": payload.rating,
        "comment": payload.comment,
        "response_adequate": payload.response_adequate,
        "submitted_at": now.isoformat(),
    }
    ref.update({"feedback": feedback, "feedback_submitted": True, "updated_at": now})
    db.collection("feedback").add({"incident_id": incident_id, **feedback})
    return {"message": "Feedback submitted"}

@app.get("/stats")
def get_stats():
    incidents = db.collection("incidents").stream()
    total = active = resolved = high = 0
    for doc in incidents:
        d = doc.to_dict()
        total += 1
        if d.get("status") == "Resolved":
            resolved += 1
        else:
            active += 1
        if d.get("severity") == "High":
            high += 1
    return {"total": total, "active": active, "resolved": resolved, "high_severity": high}