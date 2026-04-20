from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.beddy_reader import build_daily_view, calculate_day_difficulty

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
        return json.load(f)