# File: app/main.py

import json
import traceback
from pathlib import Path
from datetime import datetime, timedelta

from app.beddy_reader import build_daily_view, calculate_day_difficulty
from app.unit_state import get_note, get_completed, get_is_room_override
from app.telegram_notify import send_message


PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_FILE = PROJECT_ROOT / "data" / "daily.json"


def generate_snapshot() -> dict:
    rows = build_daily_view()
    difficulty = calculate_day_difficulty(rows)

    for row in rows:
        row["internal_note"] = get_note(row["unit_name"])
        row["completed"] = get_completed(row["unit_name"])
        row["is_room_override"] = get_is_room_override(row["unit_name"])

    target_date = datetime.now() + timedelta(days=1)

    payload = {
        "status": "ok",
        "date": target_date.strftime("%d/%m/%Y"),
        "difficulty": difficulty,
        "units": rows,
    }

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    print(f"daily.json aggiornato correttamente: {OUTPUT_FILE}")

    return payload


def main() -> None:
    try:
        payload = generate_snapshot()

        send_message(
            "✅ Housekeeping Hub\n\n"
            "Run giornaliera completata correttamente.\n"
            f"Data generata: {payload['date']}\n"
            f"Difficoltà: {payload['difficulty']}\n"
            f"Unità: {len(payload['units'])}"
        )

        print("Notifica Telegram inviata correttamente.")

    except Exception as error:
        error_text = traceback.format_exc()
        print(error_text)

        try:
            send_message(
                "❌ Housekeeping Hub\n\n"
                "Run giornaliera NON riuscita.\n\n"
                f"Errore:\n{error}"
            )
            print("Notifica Telegram errore inviata correttamente.")
        except Exception as telegram_error:
            print(f"Errore invio notifica Telegram: {telegram_error}")

        raise


if __name__ == "__main__":
    main()


# EOF - main.py