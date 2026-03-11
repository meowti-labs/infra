#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-compose/nginx/docker-compose.yml}"
CONTAINER_NAME="${CONTAINER_NAME:-infra-nginx}"
DOMAIN="${DOMAIN:-dl.meowti.kr}"

pass() {
  echo "[PASS] $*"
}

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

require_cmd docker
require_cmd curl

[[ -f "$COMPOSE_FILE" ]] || fail "compose file not found: $COMPOSE_FILE"

configured_restart="$(docker compose -f "$COMPOSE_FILE" config | awk '/restart:/ { print $2; exit }')"
[[ "$configured_restart" == "unless-stopped" ]] || fail "compose restart policy is '$configured_restart' (expected: unless-stopped)"
pass "compose restart policy is unless-stopped"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  fail "container not running: $CONTAINER_NAME"
fi
pass "container is running: $CONTAINER_NAME"

runtime_restart="$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$CONTAINER_NAME")"
[[ "$runtime_restart" == "unless-stopped" ]] || fail "runtime restart policy is '$runtime_restart' (expected: unless-stopped)"
pass "runtime restart policy is unless-stopped"

health_status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CONTAINER_NAME")"
[[ "$health_status" == "healthy" ]] || fail "container health is '$health_status' (expected: healthy)"
pass "container health is healthy"

health_code="$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" "http://127.0.0.1/healthz")"
[[ "$health_code" == "200" ]] || fail "local /healthz status is '$health_code' (expected: 200)"
pass "local /healthz status is 200"

echo "RESULT: PASS"
