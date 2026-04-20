# File: app/beddy_detail_extractor.py

from __future__ import annotations

import re
from playwright.sync_api import Page


MONTH_MAP = {
    "gen": "JAN",
    "feb": "FEB",
    "mar": "MAR",
    "apr": "APR",
    "mag": "MAY",
    "giu": "JUN",
    "lug": "JUL",
    "ago": "AUG",
    "set": "SEP",
    "ott": "OCT",
    "nov": "NOV",
    "dic": "DEC",
}


COUNTRY_PATTERN = (
    r"ITALIA|GERMANIA|FRANCIA|SPAGNA|PAESI BASSI|POLONIA|BELGIO|SVIZZERA|"
    r"AUSTRIA|REGNO UNITO|STATI UNITI|USA|IRLANDA|PORTOGALLO|ROMANIA|"
    r"REPUBBLICA CECA|UNGHERIA|CANADA|AUSTRALIA"
)


def _clean_text(value: str) -> str:
    return " ".join((value or "").split()).strip()


def _extract_booking_id(page_text: str, page_url: str) -> str:
    booking_id_match = re.search(r"#\s*([0-9]{6,})\s*\(", page_text)
    if booking_id_match:
        return booking_id_match.group(1).strip()

    booking_id_from_url = re.search(r"/reservation/(\d+)", page_url)
    if booking_id_from_url:
        return booking_id_from_url.group(1).strip()

    return ""


def _extract_guest_name(page_title: str) -> str:
    title_name_match = re.match(r"^(.*?)\s*\|\s*Beddy$", page_title)
    return title_name_match.group(1).strip() if title_name_match else ""


def _extract_origin_from_dom(page: Page) -> str:
    candidates = page.locator("div.nowrap.ng-star-inserted")
    count = candidates.count()

    for i in range(count):
        try:
            text = _clean_text(candidates.nth(i).inner_text())
            if re.fullmatch(COUNTRY_PATTERN, text, re.IGNORECASE):
                return text.upper()
        except Exception:
            continue

    return ""


def _extract_origin_from_text(page_text: str) -> tuple[str, str, bool]:
    origin_block_match = re.search(
        rf"\n([A-ZÀ-Ý' ()-]+)\n({COUNTRY_PATTERN})\n",
        page_text
    )

    origin_label_raw = origin_block_match.group(1).strip() if origin_block_match else ""
    origin_country_raw = origin_block_match.group(2).strip().upper() if origin_block_match else ""
    is_italian = origin_country_raw == "ITALIA"

    return origin_label_raw, origin_country_raw, is_italian


def _extract_origin(page: Page, page_text: str) -> tuple[str, str, bool]:
    country_from_dom = _extract_origin_from_dom(page)
    if country_from_dom:
        return "", country_from_dom, country_from_dom == "ITALIA"

    return _extract_origin_from_text(page_text)


def _parse_vertical_date(label: str, page_text: str) -> str:
    match = re.search(
        rf"{label}\s*\n[A-Za-zÀ-Ý]{{2,}},?\s*\n(\d{{1,2}})\s*\n([a-z]{{3}})\s*(\d{{2}})",
        page_text,
        re.IGNORECASE
    )
    if not match:
        return ""

    day = match.group(1).strip()
    month_it = match.group(2).strip().lower()
    year_2 = match.group(3).strip()

    month_en = MONTH_MAP.get(month_it, month_it.upper())
    year_4 = f"20{year_2}"

    return f"{day} {month_en} {year_4}"


def _extract_dates(page_text: str) -> tuple[str, str]:
    date_range_match = re.search(
        r"(\d{1,2}\s+[A-Z]{3}\s+\d{4})\s*-\s*(\d{1,2}\s+[A-Z]{3}\s+\d{4})\s*-\s*\d+\s+NOTT[EI]",
        page_text,
        re.IGNORECASE
    )
    checkin_date_raw = date_range_match.group(1).strip() if date_range_match else ""
    checkout_date_raw = date_range_match.group(2).strip() if date_range_match else ""

    if not checkin_date_raw:
        checkin_date_raw = _parse_vertical_date("Check-In", page_text)

    if not checkout_date_raw:
        checkout_date_raw = _parse_vertical_date("Check-Out", page_text)

    return checkin_date_raw, checkout_date_raw


def _extract_booking_status(page_text: str) -> str:
    booking_status_match = re.search(r"Stato della prenotazione\s*\n([A-Za-zÀ-Ý ]+)", page_text)
    return booking_status_match.group(1).strip() if booking_status_match else ""


def _extract_unit_name(page_text: str) -> str:
    unit_name_match = re.search(r"Alloggio assegnato\s*\n(.+)", page_text)
    return unit_name_match.group(1).strip() if unit_name_match else ""


def _extract_room_number(page_text: str) -> str:
    room_number_match = re.search(r"\bNumero\s*\n\s*(\d+)\b", page_text)
    return room_number_match.group(1) if room_number_match else ""


def _extract_guests(page_text: str) -> tuple[int, int, int]:
    guests_match = re.search(r"(\d+)\s+Ospiti\s*>\s*(\d+)\s+Adulti\s*,\s*(\d+)\s+Bambini", page_text)
    if not guests_match:
        return 0, 0, 0

    guests_total = int(guests_match.group(1))
    adults_count = int(guests_match.group(2))
    children_count = int(guests_match.group(3))
    return guests_total, adults_count, children_count


def _extract_phone_raw(page: Page) -> str:
    phone_links = page.locator('a[href^="tel:"]')
    count = phone_links.count()

    for i in range(count):
        try:
            href_value = phone_links.nth(i).get_attribute("href") or ""
            href_value = href_value.strip()

            if href_value.lower().startswith("tel:"):
                phone = href_value[4:].strip()
                if phone:
                    return phone

            text_value = _clean_text(phone_links.nth(i).inner_text())
            if text_value.startswith("+") or text_value.replace(" ", "").isdigit():
                return text_value
        except Exception:
            continue

    return ""


def _extract_beddy_notes(page: Page) -> str:
    try:
        note_header = page.locator("div.title-row", has_text="Appunti sulla prenotazione").first
        note_header.wait_for(timeout=3000)

        if note_header.count() > 0 and note_header.is_visible():
            note_header.click()
            page.wait_for_timeout(500)

        textarea = page.locator("textarea").filter(has_text="").nth(2)
        if textarea.count() > 0:
            value = textarea.input_value().strip()
            if value:
                return _clean_text(value)

    except Exception as e:
        print(f"WARNING: impossibile leggere Appunti sulla prenotazione -> {e}")

    return ""


def extract_booking_detail(page: Page) -> dict:
    """
    Estrae i campi principali dalla pagina dettaglio prenotazione Beddy.
    Versione adattata per Guest_Welcome_Agent:
    - telefono da DOM selector a[href^="tel:"]
    - nazionalità da DOM con fallback testuale
    - fallback robusti per date e booking_id
    """
    page.wait_for_timeout(1500)

    page_text = page.locator("body").inner_text()
    page_title = page.title().strip()
    page_url = page.url

    booking_id = _extract_booking_id(page_text, page_url)
    guest_name = _extract_guest_name(page_title)

    origin_label_raw, origin_country_raw, is_italian = _extract_origin(page, page_text)
    origin_missing = not origin_country_raw

    checkin_date_raw, checkout_date_raw = _extract_dates(page_text)
    booking_status = _extract_booking_status(page_text)
    unit_name = _extract_unit_name(page_text)
    room_number = _extract_room_number(page_text)
    beddy_notes = _extract_beddy_notes(page)
    guests_total, adults_count, children_count = _extract_guests(page_text)
    phone_raw = _extract_phone_raw(page)

    if origin_missing:
        print("WARNING: provenienza mancante nella pagina prenotazione")
        print(f"BOOKING_ID: {booking_id}")
        print(f"GUEST_NAME: {guest_name}")
        print(f"ORIGIN_LABEL_RAW: '{origin_label_raw}'")
        print(f"ORIGIN_COUNTRY_RAW: '{origin_country_raw}'")
        print(f"PAGE_URL: {page_url}")

    if not phone_raw:
        print("WARNING: telefono mancante nella pagina prenotazione")
        print(f"BOOKING_ID: {booking_id}")
        print(f"GUEST_NAME: {guest_name}")
        print(f"PAGE_URL: {page_url}")

    return {
        "booking_id": booking_id,
        "guest_name": guest_name,
        "phone_raw": phone_raw,
        "origin_label_raw": origin_label_raw,
        "origin_country_raw": origin_country_raw,
        "origin_missing": origin_missing,
        "is_italian": is_italian,
        "checkin_date_raw": checkin_date_raw,
        "checkout_date_raw": checkout_date_raw,
        "booking_status": booking_status,
        "unit_name": unit_name,
        "room_number": room_number,
        "beddy_notes": beddy_notes,
        "guests_total": guests_total,
        "adults_count": adults_count,
        "children_count": children_count,
    }


# EOF - app/beddy_detail_extractor.py