# File: app/beddy_reader.py

from __future__ import annotations

from datetime import datetime, timedelta
from typing import Dict, List

from app.beddy_tableau_reader import read_day_bookings


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

    today_bookings = read_day_bookings(0)
    tomorrow_bookings = read_day_bookings(1)

    today_map = {}
    tomorrow_map = {}

    for booking in today_bookings:
        unit_name = normalize_unit_name(
            raw=booking.get("accommodation_type", ""),
            room_number=booking.get("room_number", ""),
        )
        today_map[unit_name] = booking

    for booking in tomorrow_bookings:
        unit_name = normalize_unit_name(
            raw=booking.get("accommodation_type", ""),
            room_number=booking.get("room_number", ""),
        )
        tomorrow_map[unit_name] = booking

    target_date = datetime.now() + timedelta(days=1)
    target_str = target_date.strftime("%d %b %Y").upper()

    for unit_name in UNITS:
        today_booking = today_map.get(unit_name)
        tomorrow_booking = tomorrow_map.get(unit_name)

        if not today_booking and not tomorrow_booking:
            continue

        source = tomorrow_booking or today_booking

        language = detect_language(source.get("country_raw", ""))
        notes = source.get("beddy_notes", "")

        if not today_booking and tomorrow_booking:
            booking_status = "check_in"
            cleaning_task = "da_rifare"

        elif today_booking and not tomorrow_booking:
            booking_status = "check_out"
            cleaning_task = "smontare"

        else:
            today_id = today_booking.get("booking_id", "")
            tomorrow_id = tomorrow_booking.get("booking_id", "")

            if today_id == tomorrow_id:
                booking_status = "overnight"

                if unit_name == "app 7":
                    cleaning_task = "niente"
                elif unit_name in ["app 5", "app 6"]:
                    cleaning_task = "niente"
                else:
                    cleaning_task = "rassetto"

            else:
                booking_status = "check_in"
                cleaning_task = "da_rifare"

        rows[unit_name] = {
            "unit_name": unit_name,
            "booking_status": booking_status,
            "cleaning_task": cleaning_task,
            "language": language,
            "beddy_notes": notes,
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