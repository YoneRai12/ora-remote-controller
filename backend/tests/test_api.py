import os
import requests

API_KEY = os.getenv("API_KEY", "changeme")
BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")
HEADERS = {"Authorization": f"Bearer {API_KEY}"}


def test_status():
    r = requests.get(f"{BASE_URL}/status", headers=HEADERS)
    print(r.status_code, r.text)


def test_mc_status():
    r = requests.get(f"{BASE_URL}/mc/status", headers=HEADERS)
    print(r.status_code, r.text)


if __name__ == "__main__":
    test_status()
    test_mc_status()
