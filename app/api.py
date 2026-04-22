from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.beddy_reader import build_daily_view, calculate_day_difficulty

from fastapi import Body
from app.unit_state import set_note, set_completed, toggle_completed, get_note, get_completed

app = FastAPI(title="Housekeeping Hub API")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"status": "online", "service": "Housekeeping Hub API"}


@app.get("/api/daily")
def daily_view():
    import json
    from pathlib import Path

    file_path = Path("data/daily.json")

    if not file_path.exists():
        return {"status": "error", "message": "daily.json not found"}

    with open(file_path, "r", encoding="utf-8") as f:
        payload = json.load(f)

    for unit in payload.get("units", []):
        unit["internal_note"] = get_note(unit.get("unit_name", ""))
        unit["completed"] = get_completed(unit.get("unit_name", ""))

    return payload


@app.post("/api/save-note")
def save_note(payload: dict = Body(...)):
    unit_name = payload.get("unit_name", "")
    note = payload.get("note", "")

    set_note(unit_name, note)

    return {"status": "ok"}

@app.post("/api/complete-unit")
def complete_unit(payload: dict = Body(...)):
    unit_name = payload.get("unit_name", "")

    new_value = toggle_completed(unit_name)

    return {
        "status": "ok",
        "completed": new_value
    }