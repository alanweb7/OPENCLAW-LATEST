#!/bin/sh
set -eu

: "${OPENCLAW_VERSION:=2026.2.26}"
: "${OPENCLAW_GATEWAY_PORT:=18789}"

if [ "$(openclaw --version)" != "$OPENCLAW_VERSION" ]; then
  echo "version mismatch" >&2
  exit 1
fi

openclaw status >/dev/null 2>&1 || exit 1
node -e "
const http = require('http');
const req = http.get({ host: '127.0.0.1', port: Number(process.env.OPENCLAW_GATEWAY_PORT || 18789), timeout: 3000 }, (res) => {
  process.exit(res.statusCode && res.statusCode < 500 ? 0 : 1);
});
req.on('error', () => process.exit(1));
req.on('timeout', () => { req.destroy(); process.exit(1); });
" || exit 1
