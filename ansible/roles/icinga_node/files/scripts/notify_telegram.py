#!/usr/bin/env python3
import requests
import argparse
import sys


if __name__ == "__main__":
    parser = argparse.ArgumentParser("notify_host_telegram.py")
    parser.add_argument("--telegram-token", required=True)
    parser.add_argument("--chat-id", required=True)
    parser.add_argument("--silent", action="store_true", default=False)
    parser.add_argument("--text", required=True)
    args = parser.parse_args()

    # sanitize text according to telegrams rules
    text = str(args.text)\
        .replace(".", "\\.")\
        .replace("-", "\\-")

    print("Sending telegram notification")
    response = requests.post(
        url=f"https://api.telegram.org/bot{args.telegram_token}/sendMessage",
        json={
            "chat_id": args.chat_id,
            "parse_mode": "MarkdownV2",
            "text": text,
            "disable_web_page_preview": True,
            "disable_notification": args.silent,
        })

    if response.status_code == 200:
        print("Successfully sent telegram notification")
    else:
        print(f"Could not send telegram notification: status={response.status_code} text={response.text}")
        sys.exit(1)
