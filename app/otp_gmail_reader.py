# File: app/otp_gmail_reader.py

from __future__ import annotations

import email
import imaplib
import re
import time
from email.message import Message

from app.gmail_credentials import GMAIL_ADDRESS, GMAIL_APP_PASSWORD


IMAP_HOST = "imap.gmail.com"
IMAP_PORT = 993


def _gmail_address() -> str:
    return GMAIL_ADDRESS.strip()


def _gmail_app_password() -> str:
    return GMAIL_APP_PASSWORD.strip().replace(" ", "")


def _extract_text_from_message(msg: Message) -> str:
    parts: list[str] = []

    def html_to_text(html: str) -> str:
        html = re.sub(r"(?is)<script.*?>.*?</script>", " ", html)
        html = re.sub(r"(?is)<style.*?>.*?</style>", " ", html)
        html = re.sub(r"(?i)<br\s*/?>", "\n", html)
        html = re.sub(r"(?i)</p>", "\n", html)
        html = re.sub(r"(?i)</div>", "\n", html)
        html = re.sub(r"(?s)<[^>]+>", " ", html)
        html = html.replace("&nbsp;", " ")
        html = html.replace("&amp;", "&")
        html = html.replace("&lt;", "<")
        html = html.replace("&gt;", ">")
        html = re.sub(r"\s+", " ", html)
        return html.strip()

    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get("Content-Disposition") or "")

            if "attachment" in content_disposition.lower():
                continue

            payload = part.get_payload(decode=True)
            charset = part.get_content_charset() or "utf-8"

            if not payload:
                continue

            try:
                decoded = payload.decode(charset, errors="ignore")
            except Exception:
                decoded = payload.decode("utf-8", errors="ignore")

            if content_type == "text/plain":
                parts.append(decoded)

            elif content_type == "text/html":
                parts.append(html_to_text(decoded))
    else:
        payload = msg.get_payload(decode=True)
        charset = msg.get_content_charset() or "utf-8"

        if payload:
            try:
                decoded = payload.decode(charset, errors="ignore")
            except Exception:
                decoded = payload.decode("utf-8", errors="ignore")

            if msg.get_content_type() == "text/html":
                parts.append(html_to_text(decoded))
            else:
                parts.append(decoded)

    return "\n".join([p for p in parts if p]).strip()


def _extract_otp_code(text: str) -> str:
    normalized = " ".join((text or "").split())

    match = re.search(r"Beddy:\s*(\d{6})\b", normalized, re.IGNORECASE)
    if match:
        return match.group(1).strip()

    return ""


def _open_mailbox() -> imaplib.IMAP4_SSL:
    mail = imaplib.IMAP4_SSL(IMAP_HOST, IMAP_PORT)
    mail.login(_gmail_address(), _gmail_app_password())
    mail.select("inbox")
    return mail


def get_latest_inbox_message_id() -> int:
    """
    Restituisce l'ID numerico più alto attualmente presente in inbox.
    Serve come baseline prima di richiedere il nuovo OTP.
    """
    mail = _open_mailbox()

    try:
        status, data = mail.search(None, "ALL")
        if status != "OK":
            return 0

        message_ids = data[0].split()
        if not message_ids:
            return 0

        return int(message_ids[-1])
    finally:
        try:
            mail.logout()
        except Exception:
            pass


def fetch_latest_beddy_otp_after_message_id(
    baseline_message_id: int,
    max_wait_seconds: int = 45,
    poll_interval_seconds: int = 3,
    first_wait_seconds: int = 5,
) -> str:
    """
    Cerca OTP Beddy solo tra le email arrivate DOPO baseline_message_id.
    Questo evita di prendere codici vecchi o mail non correlate.
    """
    time.sleep(first_wait_seconds)
    deadline = time.time() + max_wait_seconds

    while time.time() < deadline:
        mail = _open_mailbox()

        try:
            status, data = mail.search(None, "ALL")
            if status != "OK":
                time.sleep(poll_interval_seconds)
                continue

            message_ids = data[0].split()
            if not message_ids:
                time.sleep(poll_interval_seconds)
                continue

            new_ids = []
            for raw_id in message_ids:
                try:
                    numeric_id = int(raw_id)
                except Exception:
                    continue

                if numeric_id > baseline_message_id:
                    new_ids.append(raw_id)

            if not new_ids:
                time.sleep(poll_interval_seconds)
                continue

            for msg_id in reversed(new_ids):
                status, msg_data = mail.fetch(msg_id, "(RFC822)")
                if status != "OK" or not msg_data or not msg_data[0]:
                    continue

                raw_email = msg_data[0][1]
                msg = email.message_from_bytes(raw_email)

                subject = str(msg.get("Subject") or "").strip()
                from_header = str(msg.get("From") or "").strip().lower()

                print("\n--- NUOVA MAIL CANDIDATA ---")
                print(f"msg_id: {msg_id.decode() if hasattr(msg_id, 'decode') else msg_id}")
                print(f"from: {from_header}")
                print(f"subject: {subject}")

                subject_ok = "pin di accesso per beddy" in subject.lower()
                from_ok = "no-reply@beddy.io" in from_header

                print(f"subject_ok: {subject_ok}")
                print(f"from_ok: {from_ok}")

                if not (subject_ok and from_ok):
                    continue

                body_text = _extract_text_from_message(msg)
                full_text = f"{subject}\n{body_text}"

                print("BODY ESTRATTO:")
                print(full_text[:1000])

                otp_code = _extract_otp_code(full_text)
                print(f"otp_code estratto: {otp_code}")

                if otp_code:
                    return otp_code

        finally:
            try:
                mail.logout()
            except Exception:
                pass

        time.sleep(poll_interval_seconds)

    return ""


if __name__ == "__main__":
    baseline = get_latest_inbox_message_id()
    print(f"Baseline inbox message id: {baseline}")
    otp_code = fetch_latest_beddy_otp_after_message_id(
        baseline_message_id=baseline,
        max_wait_seconds=15,
        poll_interval_seconds=3,
        first_wait_seconds=5,
    )
    print(f"OTP trovato: {otp_code}")


# EOF - app/otp_gmail_reader.py