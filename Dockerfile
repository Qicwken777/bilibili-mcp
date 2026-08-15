FROM python:3.11-slim

# ffmpeg is required for automatic cover-frame extraction on video upload
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt mcp-proxy

COPY mcp_server.py bili_login.py ./
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# All state that needs to survive rebuilds/restarts (login credential,
# temporary QR code) lives here — mount a volume at /app/data.
RUN mkdir -p /app/data
VOLUME ["/app/data"]

# mcp-proxy wraps mcp_server.py's stdio session and re-exposes it as an
# SSE endpoint on this port, so remote MCP clients (like ChatLuna/Koishi)
# can connect over the network instead of spawning a local process.
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mcp-proxy", "--host=0.0.0.0", "--port=8080", "python", "mcp_server.py"]
