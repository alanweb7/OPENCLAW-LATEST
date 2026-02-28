#!/bin/sh
set -eu

: "${OPENCLAW_HOME:=/home/node/.openclaw}"

mkdir -p "$OPENCLAW_HOME/state" "$OPENCLAW_HOME/sessions" "$OPENCLAW_HOME/memory" "$OPENCLAW_HOME/logs" "$OPENCLAW_HOME/workspace"

if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
  umask 077
  printf '{}\n' > "$OPENCLAW_HOME/openclaw.json"
fi

echo "[bootstrap] OpenClaw version: $(openclaw --version)"
echo "[bootstrap] OpenClaw home: $OPENCLAW_HOME"

exec "$@"
