#!/bin/sh
set -eu

: "${OPENCLAW_HOME:=/home/node/.openclaw}"
: "${OPENCLAW_GATEWAY_PORT:=18789}"
: "${OPENCLAW_CONTROLUI_ALLOWED_ORIGINS:=http://localhost:${OPENCLAW_GATEWAY_PORT},http://127.0.0.1:${OPENCLAW_GATEWAY_PORT}}"
: "${TMPDIR:=${OPENCLAW_HOME}/tmp}"

if [ "$(id -u)" -eq 0 ]; then
  mkdir -p "$OPENCLAW_HOME" \
    "$OPENCLAW_HOME/state" \
    "$OPENCLAW_HOME/sessions" \
    "$OPENCLAW_HOME/memory" \
    "$OPENCLAW_HOME/logs" \
    "$OPENCLAW_HOME/workspace" \
    "$TMPDIR"
  chown -R node:node "$OPENCLAW_HOME"
  if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
    umask 077
    printf '{}\n' > "$OPENCLAW_HOME/openclaw.json"
    chown node:node "$OPENCLAW_HOME/openclaw.json"
  fi
  node <<'NODE'
const fs = require("fs");

const cfgPath = process.env.OPENCLAW_HOME + "/openclaw.json";
const origins = (process.env.OPENCLAW_CONTROLUI_ALLOWED_ORIGINS || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

let cfg = {};
try {
  cfg = JSON.parse(fs.readFileSync(cfgPath, "utf8"));
} catch {
  cfg = {};
}

cfg.gateway = cfg.gateway || {};
cfg.gateway.controlUi = cfg.gateway.controlUi || {};
if (!Array.isArray(cfg.gateway.controlUi.allowedOrigins) || cfg.gateway.controlUi.allowedOrigins.length === 0) {
  cfg.gateway.controlUi.allowedOrigins = origins;
}

fs.writeFileSync(cfgPath, JSON.stringify(cfg, null, 2) + "\n", { mode: 0o600 });
NODE
  chown node:node "$OPENCLAW_HOME/openclaw.json"
  echo "[bootstrap] OpenClaw version: $(openclaw --version)"
  echo "[bootstrap] OpenClaw home: $OPENCLAW_HOME"
  export TMPDIR
  exec gosu node "$@"
fi

mkdir -p "$OPENCLAW_HOME/state" "$OPENCLAW_HOME/sessions" "$OPENCLAW_HOME/memory" "$OPENCLAW_HOME/logs" "$OPENCLAW_HOME/workspace" "$TMPDIR"

if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
  umask 077
  printf '{}\n' > "$OPENCLAW_HOME/openclaw.json"
fi

node <<'NODE'
const fs = require("fs");

const cfgPath = process.env.OPENCLAW_HOME + "/openclaw.json";
const origins = (process.env.OPENCLAW_CONTROLUI_ALLOWED_ORIGINS || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

let cfg = {};
try {
  cfg = JSON.parse(fs.readFileSync(cfgPath, "utf8"));
} catch {
  cfg = {};
}

cfg.gateway = cfg.gateway || {};
cfg.gateway.controlUi = cfg.gateway.controlUi || {};
if (!Array.isArray(cfg.gateway.controlUi.allowedOrigins) || cfg.gateway.controlUi.allowedOrigins.length === 0) {
  cfg.gateway.controlUi.allowedOrigins = origins;
}

fs.writeFileSync(cfgPath, JSON.stringify(cfg, null, 2) + "\n", { mode: 0o600 });
NODE

echo "[bootstrap] OpenClaw version: $(openclaw --version)"
echo "[bootstrap] OpenClaw home: $OPENCLAW_HOME"
export TMPDIR

exec "$@"
