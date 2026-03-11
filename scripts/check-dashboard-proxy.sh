#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-compose/nginx/docker-compose.yml}"
CONF_FILE="${CONF_FILE:-nginx/conf.d/dashboard.meowti.kr.conf}"
CONTAINER_NAME="${CONTAINER_NAME:-infra-nginx}"
DOMAIN="${DOMAIN:-dashboard.meowti.kr}"
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

grep -q 'set \$dashboard_upstream dashboard:3000;' "$CONF_FILE" || fail "dashboard upstream variable not configured as dashboard:3000"
pass "dashboard upstream variable is dashboard:3000"

grep -q 'proxy_pass http://\$dashboard_upstream;' "$CONF_FILE" || fail "proxy_pass is not using dashboard_upstream variable"
pass "proxy_pass uses dashboard_upstream variable"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  fail "container not running: $CONTAINER_NAME"
fi
pass "container is running: $CONTAINER_NAME"

if ! docker inspect -f '{{json .NetworkSettings.Networks}}' "$CONTAINER_NAME" | grep -q "$NETWORK_NAME"; then
  fail "container network missing: $NETWORK_NAME"
fi
pass "container network includes $NETWORK_NAME"

local_root_code="$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" "http://127.0.0.1/")"
[[ "$local_root_code" == "200" ]] || fail "local / status is '$local_root_code' (expected: 200)"
pass "local / status is 200"

echo "RESULT: PASS"
