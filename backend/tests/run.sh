#!/bin/bash
set -e
export API_KEY=changeme
uvicorn backend.main:app --port 8000 &
PID=$!
sleep 2
python backend/tests/test_api.py
kill $PID
