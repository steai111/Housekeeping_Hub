# File: app/beddy_session.py
# Gestione sessione browser Playwright per Housekeeping Hub

from __future__ import annotations

import time
from pathlib import Path

from playwright.sync_api import (
    Browser,
    BrowserContext,
    Page,
    Playwright,
    sync_playwright,
)

from app.beddy_credentials import BEDDY_USERNAME, BEDDY_PASSWORD
from app.otp_gmail_reader import (
    fetch_latest_beddy_otp_after_message_id,
    get_latest_inbox_message_id,
)


PROJECT_ROOT = Path(__file__).resolve().parent.parent
SESSION_DIR = PROJECT_ROOT / "data" / "session"
SESSION_FILE = SESSION_DIR / "beddy_session.json"

BEDDY_LOGIN_URL = "https://app.beddy.io/login"


def ensure_session_folder() -> None:
    SESSION_DIR.mkdir(parents=True, exist_ok=True)


def _perform_login_with_email_otp(page: Page, context: BrowserContext) -> None:
    print("Sessione non valida o assente. Avvio login Beddy con OTP email automatica.")

    username_input = page.locator('input[formcontrolname="username"]')
    username_input.wait_for(timeout=10000)
    username_input.fill(BEDDY_USERNAME)

    password_input = page.locator('input[formcontrolname="password"]')
    password_input.wait_for(timeout=10000)
    password_input.fill(BEDDY_PASSWORD)

    login_button = page.locator('button[type="submit"]')
    login_button.wait_for(timeout=10000)
    login_button.click()
    page.wait_for_load_state("networkidle")

    otp_selector = page.locator("nz-select-item")
    otp_selector.wait_for(timeout=10000)
    otp_selector.click()

    page.get_by_text("Autenticazione con email", exact=False).click()
    page.get_by_text("Avanti", exact=False).click()
    page.wait_for_load_state("networkidle")

    baseline_message_id = get_latest_inbox_message_id()
    print(f"Baseline inbox message id: {baseline_message_id}")

    otp_code = fetch_latest_beddy_otp_after_message_id(
        baseline_message_id=baseline_message_id,
        max_wait_seconds=45,
        poll_interval_seconds=3,
        first_wait_seconds=6,
    )

    if not otp_code:
        raise RuntimeError(
            "OTP Beddy non trovato automaticamente sulla mail entro il tempo massimo."
        )

    print(f"OTP recuperato automaticamente da Gmail: {otp_code}")

    pin_input = page.locator('input[formcontrolname="pin"]')
    pin_input.wait_for(timeout=10000)
    pin_input.fill(otp_code)
    page.wait_for_timeout(800)

    final_login_button = page.locator('button[type="submit"]')
    final_login_button.wait_for(timeout=10000)
    final_login_button.click(force=True)
    page.wait_for_timeout(2000)

    login_completed = False
    for _ in range(20):
        page.wait_for_load_state("networkidle")
        current_url = page.url
        print(f"URL durante attesa login OTP: {current_url}")

        if "login" not in current_url.lower():
            login_completed = True
            break

        time.sleep(1)

    if not login_completed:
        raise RuntimeError(
            f"Login OTP non completato: URL finale ancora su login -> {page.url}"
        )

    context.storage_state(path=str(SESSION_FILE))
    print("Login completato e sessione aggiornata.")


def open_beddy_session(target_url: str, headless: bool = False) -> Page:
    """
    Apre una sessione Beddy riutilizzando storage_state se presente.
    Se la sessione non è valida, esegue login automatico con OTP via Gmail.
    Alla fine atterra sulla target_url richiesta e restituisce la page viva.
    """
    ensure_session_folder()

    playwright: Playwright = sync_playwright().start()
    browser: Browser = playwright.chromium.launch(headless=headless)

    if SESSION_FILE.exists():
        context: BrowserContext = browser.new_context(storage_state=str(SESSION_FILE))
        print("Sessione Beddy caricata correttamente.")
    else:
        context = browser.new_context()
        print("Nessuna sessione trovata. Browser aperto senza sessione salvata.")

    page: Page = context.new_page()
    page.goto(target_url, wait_until="domcontentloaded")
    page.wait_for_load_state("networkidle")

    if "login" in page.url.lower():
        _perform_login_with_email_otp(page, context)
        page.goto(target_url, wait_until="domcontentloaded")
        page.wait_for_load_state("networkidle")

    print(f"Pagina pronta. URL corrente: {page.url}")

    page._beddy_browser = browser
    page._beddy_context = context
    page._beddy_playwright = playwright

    return page


def close_beddy_session(page: Page) -> None:
    """Chiude correttamente browser e Playwright."""
    page._beddy_browser.close()
    page._beddy_playwright.stop()


if __name__ == "__main__":
    test_url = "https://app.beddy.io/tableau"
    page = open_beddy_session(test_url, headless=False)
    input("Premi INVIO per chiudere il browser... ")
    close_beddy_session(page)


# EOF - beddy_session.py