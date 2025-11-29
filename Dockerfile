# Dockerfile for Render (Python 3.12)
FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps: tesseract, ffmpeg, fonts and browser deps for Playwright
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg unzip zip wget build-essential \
    tesseract-ocr tesseract-ocr-eng ffmpeg \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libx11-6 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libasound2 \
    fonts-dejavu locales \
    && rm -rf /var/lib/apt/lists/*

# Ensure UTF-8 locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Copy requirements first to leverage Docker cache
COPY requirements.txt /app/requirements.txt

# Upgrade pip and install python deps
RUN python -m pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy project files
COPY . /app

# Install Playwright and browsers with OS deps
RUN pip install --no-cache-dir playwright && \
    python -m playwright install --with-deps chromium

# Add start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 7860

CMD ["/app/start.sh"]
