# File: app/beddy_reader.py

from __future__ import annotations

from datetime import datetime, timedelta
from typing import Dict, List

from app.beddy_tableau_reader import read_target_day_bookings


UNITS = [
    "camera 1",
    "camera 2",
    "camera 3",
    "camera 4",
    "app 5",
    "app 6",
    "app 7",
]


def normalize_unit_name(raw: str, room_number: str = "") -> str:
    room = (room_number or "").strip()

    room_mapping = {
        "1": "camera 1",
        "2": "camera 2",
        "3": "camera 3",
        "4": "camera 4",
        "5": "app 5",
        "6": "app 6",
        "7": "app 7",
    }

    if room in room_mapping:
        return room_mapping[room]

    value = (raw or "").strip().lower()

    text_mapping = {
        "camera 1": "camera 1",
        "camera 2": "camera 2",
        "camera 3": "camera 3",
        "camera 4": "camera 4",
        "app 5": "app 5",
        "app 6": "app 6",
        "app 7": "app 7",
        "appartamento 5": "app 5",
        "appartamento 6": "app 6",
        "appartamento 7": "app 7",
    }

    return text_mapping.get(value, value)


def detect_language(country_raw: str) -> str:
    if (country_raw or "").strip().upper() == "ITALIA":
        return "IT"
    return "ENG"


def build_empty_daily_row(unit_name: str) -> dict:
    return {
        "unit_name": unit_name,
        "booking_status": "empty",
        "cleaning_task": "niente",
        "language": "-",
        "beddy_notes": "",
    }


def build_daily_view() -> List[dict]:
    from datetime import datetime

    rows: Dict[str, dict] = {
        unit: build_empty_daily_row(unit)
        for unit in UNITS
    }

    bookings = read_target_day_bookings()

    target_date = datetime.now() + timedelta(days=1)
    target_str = target_date.strftime("%d %b %Y").upper()

    for booking in bookings:
        raw_unit = booking.get("accommodation_type", "")

        unit_name = normalize_unit_name(
            raw=raw_unit,
            room_number=booking.get("room_number", ""),
        )

        if unit_name not in rows:
            continue

        checkin = booking.get("checkin_date", "").strip().upper()
        checkout = booking.get("checkout_date", "").strip().upper()

        if checkin == target_str:
            booking_status = "check_in"
            cleaning_task = "da_rifare"

        elif checkout == target_str:
            booking_status = "check_out"
            cleaning_task = "smontare"

        else:
            booking_status = "overnight"

            if unit_name in ["app 5", "app 6", "app 7"]:
                cleaning_task = "niente"
            else:
                cleaning_task = "rassetto"

        rows[unit_name] = {
            "unit_name": unit_name,
            "booking_status": booking_status,
            "cleaning_task": cleaning_task,
            "language": detect_language(booking.get("country_raw", "")),
            "beddy_notes": booking.get("beddy_notes", ""),
        }

    return list(rows.values())


def calculate_day_difficulty(rows: List[dict]) -> str:
    score = 0

    for row in rows:
        task = row["cleaning_task"]

        if task == "da_rifare":
            score += 3
        elif task == "smontare":
            score += 2
        elif task == "rassetto":
            score += 1

    if score <= 4:
        return "LIGHT"

    if score <= 10:
        return "MEDIUM"

    return "HEAVY"


if __name__ == "__main__":
    rows = build_daily_view()
    difficulty = calculate_day_difficulty(rows)

    print("\nHOUSEKEEPING HUB - DAILY VIEW\n")
    print(f"Difficulty: {difficulty}\n")

    for row in rows:
        print(row)


# EOF - beddy_reader.py