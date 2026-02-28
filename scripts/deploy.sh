#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-up}"
SERVICE="openclaw-gateway"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "[deploy] .env created from .env.example"
fi

mkdir -p data/openclaw backups

case "$ACTION" in
  up)
    docker compose up -d --build "$SERVICE"
    ;;
  restart)
    docker compose up -d --no-deps --force-recreate "$SERVICE"
    ;;
  status)
    docker compose ps "$SERVICE"
    docker compose exec -T "$SERVICE" openclaw status
    exit 0
    ;;
  *)
    echo "Usage: ./scripts/deploy.sh [up|restart|status]" >&2
    exit 1
    ;;
esac

echo "[deploy] validating pinned version"
docker compose exec -T "$SERVICE" openclaw --version
echo "[deploy] validating runtime status"
docker compose exec -T "$SERVICE" openclaw status
docker compose ps "$SERVICE"