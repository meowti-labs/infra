#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${DOMAIN:-dl.meowti.kr}"
WEB_ROOT="${WEB_ROOT:-/srv/web/dl.meowti.kr/files}"
INSTANCE_PATH="${INSTANCE_PATH:-/instance.zip}"
SHA_PATH="${SHA_PATH:-/instance.sha256}"

fail_count=0

pass() {
  echo "[PASS] $*"
}

fail() {
  echo "[FAIL] $*" >&2
  fail_count=$((fail_count + 1))
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERR: required command not found: $1" >&2
    exit 2
  }
}

first_status_code() {
  awk 'toupper($1) ~ /^HTTP\// {print $2; exit}'
}

first_location() {
  awk 'tolower($1) == "location:" {print $2; exit}' | tr -d '\r'
}

require_cmd curl
require_cmd sha256sum
require_cmd readlink
require_cmd awk

latest_zip="$WEB_ROOT/instance.zip"
latest_sha="$WEB_ROOT/instance.sha256"
instances_dir="$WEB_ROOT/instances"

if [[ -e "$latest_zip" ]]; then
  pass "latest zip exists: $latest_zip"
else
  fail "latest zip missing: $latest_zip"
fi

if [[ -e "$latest_sha" ]]; then
  pass "latest sha exists: $latest_sha"
else
  fail "latest sha missing: $latest_sha"
fi

if compgen -G "$instances_dir/instance-*.zip" >/dev/null; then
  pass "versioned zip exists in: $instances_dir"
else
  fail "no versioned zip found in: $instances_dir"
fi

http_headers="$(curl -sSI --max-time 20 "http://$DOMAIN$INSTANCE_PATH" || true)"
http_status="$(printf '%s\n' "$http_headers" | first_status_code)"
http_location="$(printf '%s\n' "$http_headers" | first_location)"

if [[ "$http_status" =~ ^(301|302|308)$ ]]; then
  pass "http redirect status: $http_status"
else
  fail "http redirect status expected 301/302/308, got: ${http_status:-none}"
fi

expected_https_location="https://$DOMAIN$INSTANCE_PATH"
if [[ "$http_location" == "$expected_https_location" ]]; then
  pass "http location header: $http_location"
else
  fail "http location expected $expected_https_location, got: ${http_location:-none}"
fi

https_zip_headers="$(curl -sSI --max-time 20 "https://$DOMAIN$INSTANCE_PATH" || true)"
https_zip_status="$(printf '%s\n' "$https_zip_headers" | first_status_code)"
if [[ "$https_zip_status" == "200" ]]; then
  pass "https instance status: 200"
else
  fail "https instance status expected 200, got: ${https_zip_status:-none}"
fi

https_sha_headers="$(curl -sSI --max-time 20 "https://$DOMAIN$SHA_PATH" || true)"
https_sha_status="$(printf '%s\n' "$https_sha_headers" | first_status_code)"
if [[ "$https_sha_status" == "200" ]]; then
  pass "https sha status: 200"
else
  fail "https sha status expected 200, got: ${https_sha_status:-none}"
fi

latest_zip_target="$(readlink -f "$latest_zip" || true)"
if [[ -n "$latest_zip_target" && -f "$latest_zip_target" ]]; then
  pass "latest zip target exists: $latest_zip_target"
else
  fail "latest zip target is invalid"
fi

sha_expected="$(awk 'NR==1 {print $1}' "$latest_sha" | tr -d '\r' || true)"
sha_actual="$(sha256sum "$latest_zip_target" | awk '{print $1}' || true)"

if [[ -n "$sha_expected" && "$sha_expected" == "$sha_actual" ]]; then
  pass "sha256 matches latest zip"
else
  fail "sha256 mismatch: expected=${sha_expected:-none} actual=${sha_actual:-none}"
fi

if [[ "$fail_count" -gt 0 ]]; then
  echo "RESULT: FAIL ($fail_count checks failed)" >&2
  exit 1
fi

echo "RESULT: PASS"
