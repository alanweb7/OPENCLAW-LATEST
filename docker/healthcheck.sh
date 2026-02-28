#!/bin/sh
set -eu

: "${OPENCLAW_VERSION:=2026.2.26}"
: "${OPENCLAW_GATEWAY_PORT:=18789}"

if [ "$(openclaw --version)" != "$OPENCLAW_VERSION" ]; then
  echo "version mismatch" >&2
  exit 1
fi

openclaw status >/dev/null 2>&1 || exit 1
curl -fsS "http://127.0.0.1:${OPENCLAW_GATEWAY_PORT}" >/dev/null 2>&1 || exit 1
