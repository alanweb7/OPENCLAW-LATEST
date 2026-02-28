#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="backups"
OUT_FILE="$OUT_DIR/openclaw_data_${TIMESTAMP}.tar.gz"

mkdir -p "$OUT_DIR"

if [[ ! -d data/openclaw ]]; then
  echo "Directory data/openclaw not found." >&2
  exit 1
fi

TO_BACKUP=("data/openclaw" "README.md" ".env.example")
if [[ -f .env ]]; then
  TO_BACKUP+=(".env")
fi

tar -czf "$OUT_FILE" "${TO_BACKUP[@]}"
echo "Backup created: $OUT_FILE"