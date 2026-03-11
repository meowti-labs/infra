#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-compose/nginx/docker-compose.yml}"
CONTAINER_NAME="${CONTAINER_NAME:-infra-nginx}"
DOMAIN="${DOMAIN:-dl.meowti.kr}"
WEB_ROOT="${WEB_ROOT:-/srv/web/dl.meowti.kr/files}"
CONF_FILE="${CONF_FILE:-nginx/conf.d/dl.meowti.kr.conf}"

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
[[ -f "$WEB_ROOT/instance.zip" ]] || fail "instance.zip not found: $WEB_ROOT/instance.zip"

if ! grep -Eq "^[[:space:]]*root[[:space:]]+$WEB_ROOT;" "$CONF_FILE"; then
  fail "nginx root is not '$WEB_ROOT' in $CONF_FILE"
fi
pass "nginx root is $WEB_ROOT"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  fail "container not running: $CONTAINER_NAME"
fi
pass "container is running: $CONTAINER_NAME"

mount_rw="$(docker inspect -f "{{range .Mounts}}{{if and (eq .Source \"$WEB_ROOT\") (eq .Destination \"$WEB_ROOT\")}}{{.RW}}{{end}}{{end}}" "$CONTAINER_NAME")"
[[ "$mount_rw" == "false" ]] || fail "web root mount is not read-only (RW=$mount_rw)"
pass "web root mount is read-only"

health_code="$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" "http://127.0.0.1/healthz")"
[[ "$health_code" == "200" ]] || fail "local /healthz status is '$health_code' (expected: 200)"
pass "local /healthz status is 200"

local_zip_code="$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" "http://127.0.0.1/instance.zip")"
[[ "$local_zip_code" == "200" ]] || fail "local /instance.zip status is '$local_zip_code' (expected: 200)"
pass "local /instance.zip status is 200"

public_zip_code="$(curl -sS -o /dev/null -w '%{http_code}' "https://$DOMAIN/instance.zip")"
[[ "$public_zip_code" == "200" ]] || fail "public https /instance.zip status is '$public_zip_code' (expected: 200)"
pass "public https /instance.zip status is 200"

echo "RESULT: PASS"
