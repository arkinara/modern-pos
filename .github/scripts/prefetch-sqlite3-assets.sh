#!/usr/bin/env bash
# Prefetch the sqlite3 precompiled native assets that the build hook would
# otherwise download from a GitHub release.
#
# The hook verifies each download against a SHA-256 pinned in the sqlite3
# package. Some CI runners receive a corrupted response from the release
# download endpoint, which makes the hook fail with "Hash of downloaded file
# ... is ..., expected ...". Fetch through the GitHub API asset endpoint (a
# different path) instead, verify the pinned hash, and place only verified
# bytes where the hook looks for its cache.
#
# Usage: prefetch-sqlite3-assets.sh <linux|android>
set -euo pipefail

target="${1:-linux}"
version=3.5.2

case "$target" in
  linux)
    assets=(
      "libsqlite3.x64.linux.so:b17729184e5a2818055ecbddd5ed6642521bfe6e56aafa472330e483c0e2e0d2"
      "libsqlite3.arm64.linux.so:7f0db19fdb987298ab8def51431aba5cec28a81685e8b62cebbc7402df090a16"
    )
    ;;
  android)
    assets=(
      "libsqlite3.arm.android.so:a42fa9d0f5c006d30b000d4904bc497705191c5d7330b178618546004295bb49"
      "libsqlite3.arm64.android.so:0c2d3bfc8c87abceb21ed72a4bb49964121c5fe1a8ef3848d83ba907d01b6161"
      "libsqlite3.ia32.android.so:3888ba23a79904b968ad7f7cd3b3f59e856a25dcc90953b5a69ea6a4f9961f59"
      "libsqlite3.x64.android.so:949965f0eba976f707ae364cdcb42c342b5f0626081f8d7f0378fb7b52848772"
    )
    ;;
  *)
    echo "Unknown sqlite3 prefetch target: $target" >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mobile_dir="$repo_root/apps/mobile"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

for entry in "${assets[@]}"; do
  asset="${entry%%:*}"
  hash="${entry##*:}"
  prefix="${hash:0:8}"
  dir="$mobile_dir/.dart_tool/hooks_runner/shared/sqlite3/build/download-$prefix"
  dest="$dir/libsqlite3.so"

  if [ -f "$dest" ] && [ "$(sha256sum "$dest" | cut -d' ' -f1)" = "$hash" ]; then
    echo "Verified sqlite3 asset already cached: $asset"
    continue
  fi

  ok=0
  for attempt in 1 2 3; do
    rm -f "$tmpdir/$asset"
    if gh release download "sqlite3-$version" \
        --repo simolus3/sqlite3.dart \
        --pattern "$asset" \
        --dir "$tmpdir" \
        --clobber; then
      got="$(sha256sum "$tmpdir/$asset" | cut -d' ' -f1)"
      if [ "$got" = "$hash" ]; then
        mkdir -p "$dir"
        cp "$tmpdir/$asset" "$dest"
        echo "Prefetched and verified $asset ($hash)"
        ok=1
        break
      fi
      echo "Prefetch attempt $attempt for $asset had hash $got; expected $hash" >&2
    else
      echo "Prefetch attempt $attempt for $asset failed to download" >&2
    fi
    sleep 5
  done

  if [ "$ok" -ne 1 ]; then
    echo "Could not prefetch a verified $asset; the build hook will download it" >&2
  fi
done

exit 0
