# # FROM python:3.10-slim

# # # --- System deps required by Playwright browsers AND Tesseract ---
# # # Added 'tesseract-ocr' to the install list
# # RUN apt-get update && apt-get install -y \
# #     wget gnupg ca-certificates curl unzip \
# #     # Playwright dependencies
# #     libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 \
# #     libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 libxrandr2 \
# #     libxfixes3 libpango-1.0-0 libcairo2 \
# #     # Tesseract OCR engine
# #     tesseract-ocr \
# #     # FFmpeg for audio processing (pydub)
# #     ffmpeg \
# #     && rm -rf /var/lib/apt/lists/*

# # # --- Install Playwright + Chromium ---
# # RUN pip install playwright && playwright install --with-deps chromium

# # # --- Install uv package manager ---
# # RUN pip install uv

# # # --- Copy app to container ---
# # WORKDIR /app

# # COPY . .

# # ENV PYTHONUNBUFFERED=1
# # ENV PYTHONIOENCODING=utf-8

# # # --- Install project dependencies using uv ---
# # RUN uv sync --frozen

# # # HuggingFace Spaces exposes port 7860
# # EXPOSE 7860

# # # --- Run your FastAPI app ---
# # # uvicorn must be in pyproject dependencies
# # CMD ["uv", "run", "main.py"]

# # Use an official Python base
# FROM python:3.12-slim
# RUN pip install --no-cache-dir google-generativeai langchain-google-genai langchain
# # prevent interactive prompts during apt installs
# ENV DEBIAN_FRONTEND=noninteractive

# # create appdir
# WORKDIR /app

# # Install system deps: build essentials, tesseract, ffmpeg, fonts, libs used by playwright
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ca-certificates curl gnupg unzip zip \
#     tesseract-ocr tesseract-ocr-eng ffmpeg \
#     libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libx11-6 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libasound2 \
#     fonts-dejavu \
#     && rm -rf /var/lib/apt/lists/*

# # copy only packaging files first for docker layer caching
# COPY pyproject.toml poetry.lock* requirements.txt* /app/

# # If you use requirements.txt:
# RUN pip install --upgrade pip setuptools wheel
# RUN if [ -f "requirements.txt" ]; then pip install --no-cache-dir -r requirements.txt; fi

# # If you use pyproject.toml, add editable install
# # RUN pip install --no-cache-dir -e .

# # copy project
# COPY . /app

# # install python deps again for safety (if pyproject used, run pip install)
# RUN pip install --no-cache-dir .

# # Install Playwright python package and browsers
# RUN pip install --no-cache-dir playwright && \
#     python -m playwright install --with-deps chromium

# # Create a small start script that uses PORT env var
# COPY start.sh /app/start.sh
# RUN chmod +x /app/start.sh

# EXPOSE 7860

# # Default cmd uses start.sh that reads $PORT
# CMD ["/app/start.sh"]

# Dockerfile for Render (Python 3.12)
FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies (tesseract, ffmpeg, fonts, browsers deps)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg unzip zip wget build-essential \
    tesseract-ocr tesseract-ocr-eng ffmpeg \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libx11-6 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libasound2 \
    fonts-dejavu locales \
    && rm -rf /var/lib/apt/lists/*

# Ensure UTF-8 locale (optional but useful)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Copy only requirements first to leverage Docker cache
COPY requirements.txt /app/requirements.txt

# Upgrade pip and install Python dependencies
RUN python -m pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the project
COPY . /app

# Install Playwright and browsers (with OS deps)
RUN pip install --no-cache-dir playwright && \
    python -m playwright install --with-deps chromium

# Add start script and make executable
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Render expects a port; we expose the default one (not strictly required)
EXPOSE 7860

# Start command: start.sh will use $PORT if present
CMD ["/app/start.sh"]

