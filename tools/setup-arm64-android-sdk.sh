#!/usr/bin/env bash
# Host-only helper for arm64 Linux machines using Google's x86-64 Android SDK tools.
# CI uses an x86-64 runner and does not need this script.
set -euo pipefail

if [ "$(uname -m)" != "aarch64" ]; then
  echo "Host is not aarch64; Android SDK needs no emulation setup."
  exit 0
fi

echo "Installing qemu-user and x86-64 cross libraries..."
sudo apt-get install -y qemu-user libc6-amd64-cross libgcc-s1-amd64-cross

echo "Wiring x86-64 loader and library paths..."
sudo mkdir -p /lib64
sudo ln -sf /usr/x86_64-linux-gnu/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
if [ ! -e /usr/lib/x86_64-linux-gnu ]; then
  sudo ln -s /usr/x86_64-linux-gnu/lib /usr/lib/x86_64-linux-gnu
fi

if [ ! -e /usr/x86_64-linux-gnu/lib/libz.so.1 ]; then
  echo "Fetching the x86-64 zlib needed by the NDK clang driver..."
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  sudo tee /etc/apt/sources.list.d/modern-pos-amd64-temp.list >/dev/null <<'EOF'
deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble main universe
deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-updates main universe
deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-security main universe
EOF

  sudo dpkg --add-architecture amd64
  sudo apt-get update || true
  (cd "$tmp_dir" && apt-get download zlib1g:amd64)
  mkdir -p "$tmp_dir/extract"
  dpkg-deb -x "$tmp_dir"/zlib1g_*amd64.deb "$tmp_dir/extract"
  sudo cp -a "$tmp_dir"/extract/usr/lib/x86_64-linux-gnu/libz.so.* /usr/x86_64-linux-gnu/lib/

  sudo rm -f /etc/apt/sources.list.d/modern-pos-amd64-temp.list
  sudo dpkg --remove-architecture amd64 || true
fi

echo "Done. The next Flutter Android build can execute the x86-64 SDK tools through binfmt."
