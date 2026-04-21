# File: app/main.py

from app.beddy_reader import build_daily_view, calculate_day_difficulty


def format_task(value: str) -> str:
    mapping = {
        "da_rifare": "Da rifare",
        "smontare": "Smontare",
        "rassetto": "Rassetto",
        "niente": "Niente",
    }
    return mapping.get(value, value)


def format_booking_status(value: str) -> str:
    mapping = {
        "check_in": "Check-in",
        "check_out": "Check-out",
        "overnight": "Pernottamento",
        "empty": "Vuota",
    }
    return mapping.get(value, value)


def print_dashboard(rows: list[dict], difficulty: str) -> None:
    print("\n==============================")
    print(" HOUSEKEEPING HUB - DAILY VIEW")
    print("==============================")
    print(f"Giornata: {difficulty}")
    print()

    for row in rows:
        print(f"• {row['unit_name'].upper()}")
        print(f"  Status: {format_booking_status(row['booking_status'])}")
        print(f"  Task: {format_task(row['cleaning_task'])}")
        print(f"  Lingua: {row['language']}")

        if row["beddy_notes"]:
            print(f"  Note: {row['beddy_notes']}")

        print()


def main() -> None:
    rows = build_daily_view()
    difficulty = calculate_day_difficulty(rows)
    print_dashboard(rows, difficulty)


if __name__ == "__main__":
    main()


# EOF - main.py