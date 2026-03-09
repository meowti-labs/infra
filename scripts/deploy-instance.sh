#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/srv/web/dl.meowti.kr/files}"
INST_DIR="$WEB_ROOT/instances"
META_DIR="$WEB_ROOT/meta"
LATEST_INSTANCE_LINK="$WEB_ROOT/instance.zip"
LATEST_SHA_LINK="$WEB_ROOT/instance.sha256"
ALIAS_COMPAT_LINK="$INST_DIR/instance.zip"

usage() {
  cat <<USAGE
Usage:
  ./scripts/deploy-instance.sh /path/to/instance.zip

Optional env:
  WEB_ROOT=/srv/web/dl.meowti.kr/files
USAGE
}

fail() {
  echo "ERR: $*" >&2
  exit 1
}

ensure_writable_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || fail "directory not found: $dir"
  [[ -w "$dir" ]] || fail "directory is not writable: $dir"
}

pick_dest_path() {
  local ts="$1"
  local candidate="$INST_DIR/instance-$ts.zip"

  if [[ ! -e "$candidate" ]]; then
    echo "$candidate"
    return
  fi

  local suffix=2
  while [[ -e "$INST_DIR/instance-$ts-$suffix.zip" ]]; do
    suffix=$((suffix + 1))
  done
  echo "$INST_DIR/instance-$ts-$suffix.zip"
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

SRC="$1"
[[ -f "$SRC" ]] || fail "input zip not found: $SRC"

mkdir -p "$INST_DIR" "$META_DIR" || fail "failed to create instance/meta directories"

ensure_writable_dir "$WEB_ROOT"
ensure_writable_dir "$INST_DIR"
ensure_writable_dir "$META_DIR"

ts="$(date +%Y%m%d-%H%M)"
DEST="$(pick_dest_path "$ts")"
DEST_TMP="$DEST.tmp.$$"

cp "$SRC" "$DEST_TMP" || fail "failed to copy input zip to staging file"
mv -f "$DEST_TMP" "$DEST" || fail "failed to move staging zip to destination"

BASE_NAME="$(basename "$DEST" .zip)"
SHA_DEST="$META_DIR/$BASE_NAME.sha256"
SHA_TMP="$SHA_DEST.tmp.$$"

sha256sum "$DEST" > "$SHA_TMP" || fail "failed to create sha256 file"
mv -f "$SHA_TMP" "$SHA_DEST" || fail "failed to move staging sha256 file"

ln -sfn "$DEST" "$LATEST_INSTANCE_LINK" || fail "failed to update latest instance link"
ln -sfn "$SHA_DEST" "$LATEST_SHA_LINK" || fail "failed to update latest sha256 link"
ln -sfn "$DEST" "$ALIAS_COMPAT_LINK" || fail "failed to update alias-compat instance link"

echo "OK:"
echo "  version zip : $DEST"
echo "  latest zip  : $LATEST_INSTANCE_LINK -> $(readlink -f "$LATEST_INSTANCE_LINK")"
echo "  alias link  : $ALIAS_COMPAT_LINK -> $(readlink -f "$ALIAS_COMPAT_LINK")"
echo "  version sha : $SHA_DEST"
echo "  latest sha  : $LATEST_SHA_LINK -> $(readlink -f "$LATEST_SHA_LINK")"
