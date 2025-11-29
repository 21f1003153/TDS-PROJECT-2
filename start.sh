#!/bin/sh
PORT=${PORT:-7860}

# Prefer uvicorn main:app if your main.py exposes `app`.
# If your main.py does NOT expose an ASGI `app`, change the exec line below to: exec python main.py

# Try uvicorn; if uvicorn isn't appropriate, replace the line with python main.py
exec uvicorn main:app --host 0.0.0.0 --port $PORT
