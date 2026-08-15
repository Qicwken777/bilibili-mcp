FROM python:3.11-slim

# ffmpeg is required for automatic cover-frame extraction on video upload
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY mcp_server.py bili_login.py ./
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# All state that needs to survive rebuilds/restarts (login credential,
# temporary QR code) lives here — mount a volume at /app/data.
RUN mkdir -p /app/data
VOLUME ["/app/data"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "mcp_server.py"]
