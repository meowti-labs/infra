#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-compose/nginx/docker-compose.yml}"
CONF_FILE="${CONF_FILE:-nginx/conf.d/api.meowti.kr.conf}"
CONTAINER_NAME="${CONTAINER_NAME:-infra-nginx}"
DOMAIN="${DOMAIN:-api.meowti.kr}"
NETWORK_NAME="${NETWORK_NAME:-frontdoor-net}"

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
[[ -f "$CONF_FILE" ]] || fail "nginx conf file not found: $CONF_FILE"

grep -q "server_name $DOMAIN;" "$CONF_FILE" || fail "server_name '$DOMAIN' not found in $CONF_FILE"
pass "nginx server_name is $DOMAIN"

grep -q 'set \$api_upstream api:8080;' "$CONF_FILE" || fail "api upstream variable not configured as api:8080"
pass "api upstream variable is api:8080"

grep -q 'proxy_pass http://\$api_upstream;' "$CONF_FILE" || fail "proxy_pass is not using api_upstream variable"
pass "proxy_pass uses api_upstream variable"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  fail "container not running: $CONTAINER_NAME"
fi
pass "container is running: $CONTAINER_NAME"

if ! docker inspect -f '{{json .NetworkSettings.Networks}}' "$CONTAINER_NAME" | grep -q "$NETWORK_NAME"; then
  fail "container network missing: $NETWORK_NAME"
fi
pass "container network includes $NETWORK_NAME"

local_health_code="$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" "http://127.0.0.1/healthz")"
[[ "$local_health_code" == "200" ]] || fail "local /healthz status is '$local_health_code' (expected: 200)"
pass "local /healthz status is 200"

echo "RESULT: PASS"
