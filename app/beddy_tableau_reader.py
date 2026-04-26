# File: app/beddy_tableau_reader.py

from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any, Dict, List

from playwright.sync_api import Page

from app.beddy_session import open_beddy_session, close_beddy_session
from app.beddy_detail_extractor import extract_booking_detail


TABLEAU_URL_BASE = "https://app.beddy.io/tableau"


def _build_target_context(offset_days: int = 1) -> dict:
    target_dt = datetime.now() + timedelta(days=offset_days)

    return {
        "target_date_iso": target_dt.strftime("%Y-%m-%d"),
        "target_day": target_dt.day,
        "target_checkin_raw": target_dt.strftime("%d %b %Y").upper(),
    }


def _build_tableau_url(target_date_iso: str) -> str:
    return f"{TABLEAU_URL_BASE}?start={target_date_iso}"


def _close_tableau_popup(page: Page) -> None:
    try:
        close_btn = page.locator("button.ant-modal-close").last
        if close_btn.count() > 0 and close_btn.is_visible():
            close_btn.click()
            page.wait_for_timeout(700)
            return
    except Exception:
        pass

    page.mouse.click(300, 80)
    page.wait_for_timeout(700)


def _find_target_day_header_index(day_headers_text: List[str], target_day: int) -> int | None:
    target_header_text = f"{target_day} "

    for index, text in enumerate(day_headers_text):
        clean_text = " ".join(text.split())
        if clean_text.startswith(target_header_text):
            return index

    return None


def _build_raw_booking(extracted: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "booking_id": extracted.get("booking_id", ""),
        "guest_name": extracted.get("guest_name", ""),
        "accommodation_type": extracted.get("unit_name", ""),
        "room_number": extracted.get("room_number", ""),
        "checkin_date": extracted.get("checkin_date_raw", ""),
        "checkout_date": extracted.get("checkout_date_raw", ""),
        "country_raw": extracted.get("origin_country_raw", ""),
        "booking_status_raw": extracted.get("booking_status", ""),
        "beddy_notes": extracted.get("beddy_notes", ""),
    }


def read_day_bookings(offset_days: int = 1) -> List[Dict[str, Any]]:
    context = _build_target_context(offset_days)

    target_date_iso = context["target_date_iso"]
    target_day = context["target_day"]
    target_checkin_raw = context["target_checkin_raw"]

    tableau_url = _build_tableau_url(target_date_iso)

    page: Page = open_beddy_session(tableau_url, headless=False)
    collected_bookings: List[Dict[str, Any]] = []
    booking_ids_seen: set[str] = set()

    try:
        print(f"URL finale reader: {page.url}")
        print(f"TITOLO PAGINA: {page.title()}")
        print(f"TARGET DATE ISO: {target_date_iso}")
        print(f"TARGET DAY: {target_day}")
        print(f"TARGET CHECK-IN RAW: {target_checkin_raw}")

        headers_text = page.locator("th").all_inner_texts()

        print("HEADER TROVATI NEL TABLEAU:")
        for index, text in enumerate(headers_text, start=1):
            clean_text = " ".join(text.split())
            if clean_text:
                print(f"{index}: {clean_text}")

        day_headers = page.locator("th.by-tableau-cell--day")
        day_headers_text = day_headers.all_inner_texts()

        print("HEADER GIORNI TROVATI NEL TABLEAU:")
        for index, text in enumerate(day_headers_text, start=1):
            clean_text = " ".join(text.split())
            if clean_text:
                print(f"{index}: {clean_text}")

        target_day_header_index = _find_target_day_header_index(day_headers_text, target_day)
        if target_day_header_index is None:
            print(f"ERRORE: nessuna colonna trovata per il giorno {target_day}")
            return []

        print(f"HEADER TARGET TROVATO: index={target_day_header_index}")

        page.wait_for_timeout(3000)
        page.wait_for_selector("div.by-tableau-reservation.by-tableau-box", timeout=10000)

        reservation_boxes = page.locator("div.by-tableau-reservation.by-tableau-box")
        boxes_count = reservation_boxes.count()
        print(f"BOX PRENOTAZIONE VISIBILI: {boxes_count}")

        target_box = day_headers.nth(target_day_header_index).bounding_box()

        if not target_box:
            print(f"ERRORE: bounding box non trovata per il giorno {target_day}")
            return []

        target_day_start_x = target_box["x"]
        target_day_end_x = target_box["x"] + target_box["width"]

        print(f"RANGE X GIORNO {target_day}: {target_day_start_x} -> {target_day_end_x}")

        starting_boxes = []

        for i in range(boxes_count):
            box_locator = reservation_boxes.nth(i)
            box_rect = box_locator.bounding_box()

            if not box_rect:
                continue

            box_x = box_rect["x"]

            if target_day_start_x <= box_x < target_day_end_x:
                box_name = box_locator.locator("div.by-tableau-reservation__content").inner_text().strip()
                starting_boxes.append((i, box_name, box_rect))
                print(f"BOX START DAY {target_day}: index={i + 1} name='{box_name}'")

        print(f"TOTALE BOX CHE INIZIANO IL GIORNO {target_day}: {len(starting_boxes)}")

        for box_index, (current_index, current_name, _) in enumerate(starting_boxes, start=1):
            print(f"\n=== BOX {box_index}/{len(starting_boxes)} DEL GIORNO {target_day} ===")
            print(f"BOX TARGET: {current_name} (index={current_index + 1})")

            current_box = reservation_boxes.nth(current_index)
            current_box.click()
            page.wait_for_timeout(2000)

            with page.expect_popup() as popup_info:
                page.locator("i.fas.fa-pen").first.click()

            detail_page = popup_info.value
            detail_page.wait_for_load_state("networkidle")

            extracted = extract_booking_detail(detail_page)

#            if extracted.get("checkin_date_raw") != target_checkin_raw:
#                print(
#                    f"SALTATO: check-in reale '{extracted.get('checkin_date_raw', '')}' "
#                    f"diverso da target '{target_checkin_raw}'"
#                )
#                detail_page.close()
#                page.wait_for_timeout(700)
#                _close_tableau_popup(page)
#                continue

            booking_id = extracted.get("booking_id", "").strip()

            if not booking_id:
                print("SALTATO: booking_id vuoto")
                detail_page.close()
                page.wait_for_timeout(700)
                _close_tableau_popup(page)
                continue

            if booking_id in booking_ids_seen:
                print(f"DUPLICATO SALTATO: {booking_id}")
                detail_page.close()
                page.wait_for_timeout(700)
                _close_tableau_popup(page)
                continue

            booking_ids_seen.add(booking_id)

            raw_booking = _build_raw_booking(extracted)
            collected_bookings.append(raw_booking)

            print(f"BOOKING RACCOLTA: {raw_booking}")

            detail_page.close()
            page.wait_for_timeout(700)
            _close_tableau_popup(page)

        return collected_bookings

    finally:
        close_beddy_session(page)


if __name__ == "__main__":
    bookings = read_day_bookings(1)
    print("\nBOOKINGS FINALI:")
    for booking in bookings:
        print(booking)


# EOF - beddy_tableau_reader.py