# #!/bin/sh
# # Render sets $PORT for you; fallback to 7860 if not present
# PORT=${PORT:-7860}
# # If your app is an ASGI app readable by uvicorn (main:app), use uvicorn:
#  exec uvicorn main:app --host 0.0.0.0 --port $PORT

# # If your app runs via `python main.py` and reads a fixed port (7860) you can still forward:
# exec python main.py
#!/bin/sh
# start.sh — use $PORT if provided by Render; fallback to 7860
PORT=${PORT:-7860}

# if your main file defines an ASGI app as "app" in main.py, use uvicorn:
# exec uvicorn main:app --host 0.0.0.0 --port $PORT

# If your main.py starts the server itself and binds to 7860, just run it:
exec python main.py
