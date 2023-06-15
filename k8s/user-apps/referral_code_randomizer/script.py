#!/usr/bin/env python3
import requests


CODE = "STAR-CJ93-RVSJ"


if __name__ == "__main__":
    payload = {
        'codeSet': 'STAR',
        'code': CODE
    }
    headers = {'X-Requested-With': 'XMLHttpRequest'}

    print(f"Updating gorefer.me code {CODE}")
    r = requests.post("https://gorefer.me/code/submit", data=payload, headers=headers)
    assert r.status_code == 200, f"Updating referral code failed with status {r.status_code}: {r.text}"
    print(f"Successfully updated code")
