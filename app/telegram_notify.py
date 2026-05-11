# File: app/telegram_notify.py

import json
import time
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.parse import urlencode


PROJECT_ROOT = Path(__file__).resolve().parent.parent
CONFIG_FILE = PROJECT_ROOT / "data" / "telegram_config.json"


def load_config() -> dict:
    if not CONFIG_FILE.exists():
        return {}

    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def save_config(config: dict) -> None:
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)


def send_message(text: str) -> None:
    config = load_config()
    token = config.get("bot_token", "")
    chat_id = config.get("chat_id", "")

    if not token or not chat_id:
        print("Telegram non configurato: bot_token o chat_id mancante.")
        return

    url = f"https://api.telegram.org/bot{token}/sendMessage"

    data = urlencode({
        "chat_id": chat_id,
        "text": text,
    }).encode("utf-8")

    request = Request(url, data=data, method="POST")

    with urlopen(request, timeout=20) as response:
        response.read()


def setup_chat_id() -> None:
    config = load_config()
    token = config.get("bot_token", "")

    if not token:
        print("ERRORE: manca bot_token in data/telegram_config.json")
        return

    print("Scrivi /start nella chat Telegram del bot.")
    print("Attendo messaggio...")

    offset = None

    while True:
        params = {}
        if offset is not None:
            params["offset"] = offset

        url = f"https://api.telegram.org/bot{token}/getUpdates"
        if params:
            url += "?" + urlencode(params)

        with urlopen(url, timeout=30) as response:
            payload = json.loads(response.read().decode("utf-8"))

        for update in payload.get("result", []):
            offset = update["update_id"] + 1

            message = update.get("message") or update.get("channel_post")
            if not message:
                continue

            chat = message.get("chat", {})
            text = message.get("text", "")

            if text.strip() == "/start":
                chat_id = chat.get("id")
                config["chat_id"] = chat_id
                save_config(config)

                reply = (
                    "✅ Housekeeping Hub Agent configurato.\n"
                    f"chat_id: {chat_id}"
                )
                send_message(reply)

                print(f"chat_id salvato: {chat_id}")
                return

        time.sleep(2)


if __name__ == "__main__":
    setup_chat_id()


# EOF - telegram_notify.py