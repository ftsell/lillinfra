#!/usr/bin/env python3
import requests
import argparse


if __name__ == "__main__":
    parser = argparse.ArgumentParser("notify_host_telegram.py")
    parser.add_argument("--telegram-token", required=True)
    parser.add_argument("--chat-id", required=True)
    parser.add_argument("--object-type", choices=["host", "service"])
    parser.add_argument("--object-state", choices=["OK", "Warning", "Critical", "Unknown", "Up", "Down"])
    parser.add_argument("--notification-type", choices=["Problem", "Recovery" ], required=True)
    parser.add_argument("--silent", action="store_true", default=False)
    parser.add_argument("--host-name", required=True)
    parser.add_argument("--service-name")
    args = parser.parse_args()

    # construct message text
    if args.notification_type == "Problem":
        if args.object_type == "host":
            header = f"*❗{args.host_name} is {args.object_state} ❗*"
        elif args.object_type == "service":
            header = f"*❗{args.service_name} is {args.object_state} ❗*"
    elif args.notification_type == "Recovery":
        if args.object_type == "host":
            header = f"*✅ {args.host_name} is {args.object_state}*"
        elif args.object_type == "service":
            header = f"*✅ {args.service_name} is {args.object_state}*"

    text = header

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
    response.raise_for_status()
