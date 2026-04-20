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
    rows = build_daily_view()
    difficulty = calculate_day_difficulty(rows)

    return {
        "status": "ok",
        "difficulty": difficulty,
        "units": rows
    }