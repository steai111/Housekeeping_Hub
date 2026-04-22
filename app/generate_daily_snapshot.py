import json
from pathlib import Path
from datetime import datetime, timedelta

from app.beddy_reader import build_daily_view, calculate_day_difficulty

from app.unit_state import get_note, get_completed


OUTPUT_FILE = Path("data/daily.json")


def generate_snapshot():
    rows = build_daily_view()
    difficulty = calculate_day_difficulty(rows)
    for row in rows:
    row["internal_note"] = get_note(row["unit_name"])
    row["completed"] = get_completed(row["unit_name"])

    target_date = datetime.now() + timedelta(days=1)

    payload = {
        "status": "ok",
        "date": target_date.strftime("%d/%m/%Y"),
        "difficulty": difficulty,
        "units": rows
    }

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    print("daily.json aggiornato correttamente.")


if __name__ == "__main__":
    generate_snapshot()