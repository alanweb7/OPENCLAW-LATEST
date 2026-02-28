#!/bin/sh
set -eu

: "${OPENCLAW_HOME:=/home/node/.openclaw}"

if [ "$(id -u)" -eq 0 ]; then
  mkdir -p "$OPENCLAW_HOME" \
    "$OPENCLAW_HOME/state" \
    "$OPENCLAW_HOME/sessions" \
    "$OPENCLAW_HOME/memory" \
    "$OPENCLAW_HOME/logs" \
    "$OPENCLAW_HOME/workspace"
  chown -R node:node "$OPENCLAW_HOME"
  if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
    umask 077
    printf '{}\n' > "$OPENCLAW_HOME/openclaw.json"
    chown node:node "$OPENCLAW_HOME/openclaw.json"
  fi
  echo "[bootstrap] OpenClaw version: $(openclaw --version)"
  echo "[bootstrap] OpenClaw home: $OPENCLAW_HOME"
  exec gosu node "$@"
fi

mkdir -p "$OPENCLAW_HOME/state" "$OPENCLAW_HOME/sessions" "$OPENCLAW_HOME/memory" "$OPENCLAW_HOME/logs" "$OPENCLAW_HOME/workspace"

if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
  umask 077
  printf '{}\n' > "$OPENCLAW_HOME/openclaw.json"
fi

echo "[bootstrap] OpenClaw version: $(openclaw --version)"
echo "[bootstrap] OpenClaw home: $OPENCLAW_HOME"

exec "$@"
