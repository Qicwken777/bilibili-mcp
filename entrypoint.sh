#!/bin/sh
set -e

# mcp_server.py always reads/writes bili_credential.json (and the temporary
# qrcode_login.png) next to itself, in /app. We can't change that without
# patching the source, so instead we point that path at the mounted
# /app/data volume via a symlink — this way login state survives
# `docker run --rm`, container restarts, and image rebuilds.
ln -sf /app/data/bili_credential.json /app/bili_credential.json

exec "$@"
