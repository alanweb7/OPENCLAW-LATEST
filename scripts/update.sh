#!/usr/bin/env bash
set -euo pipefail

SERVICE="openclaw-gateway"
TARGET_VERSION="${1:-}"

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

if [[ -n "$TARGET_VERSION" ]]; then
  sed -i.bak -E "s/^OPENCLAW_VERSION=.*/OPENCLAW_VERSION=${TARGET_VERSION}/" .env
  sed -i.bak -E "s|^OPENCLAW_IMAGE_NAME=.*|OPENCLAW_IMAGE_NAME=openclaw:${TARGET_VERSION}|" .env
  rm -f .env.bak
fi

docker compose build --pull "$SERVICE"
docker compose up -d --no-deps --force-recreate "$SERVICE"

echo "[update] running version:"
docker compose exec -T "$SERVICE" openclaw --version
echo "[update] running status:"
docker compose exec -T "$SERVICE" openclaw status