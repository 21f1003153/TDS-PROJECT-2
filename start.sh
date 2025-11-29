#!/bin/sh
# Render sets $PORT for you; fallback to 7860 if not present
PORT=${PORT:-7860}
# If your app is an ASGI app readable by uvicorn (main:app), use uvicorn:
# exec uvicorn main:app --host 0.0.0.0 --port $PORT

# If your app runs via `python main.py` and reads a fixed port (7860) you can still forward:
exec python main.py
