import json
from pathlib import Path


STATE_FILE = Path("data/unit_state.json")


def normalize_unit_name(unit_name):
    return (unit_name or "").strip().lower()


def load_state():
    if not STATE_FILE.exists():
        return {}

    with open(STATE_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def save_state(data):
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def get_note(unit_name):
    data = load_state()
    key = normalize_unit_name(unit_name)
    return data.get(key, {}).get("note", "")


def set_note(unit_name, note):
    data = load_state()
    key = normalize_unit_name(unit_name)

    if key not in data:
        data[key] = {}

    data[key]["note"] = note

    save_state(data)

def get_completed(unit_name):
    data = load_state()
    key = normalize_unit_name(unit_name)
    return data.get(key, {}).get("completed", False)


def set_completed(unit_name, value):
    data = load_state()
    key = normalize_unit_name(unit_name)

    if key not in data:
        data[key] = {}

    data[key]["completed"] = value

    save_state(data)

def toggle_completed(unit_name):
    data = load_state()
    key = normalize_unit_name(unit_name)

    if key not in data:
        data[key] = {}

    current_value = data[key].get("completed", False)
    new_value = not current_value

    data[key]["completed"] = new_value

    if new_value is True:
        data[key]["note"] = ""

    save_state(data)

    return new_value