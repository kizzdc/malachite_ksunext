#!/usr/bin/env bash
set -euo pipefail
cd gki
mkdir -p dist

# Android's Kleaf kernel_aarch64_dist supports --destdir.
# Capture complete log and keep failures visible.
set -o pipefail
tools/bazel run --config=fast //common:kernel_aarch64_dist -- \
  "--destdir=$PWD/dist" 2>&1 | tee build.log

if [[ ! -s dist/Image && ! -s dist/Image.lz4 ]]; then
  echo 'ERROR: Neither Image nor Image.lz4 was generated.' >&2
  exit 6
fi

# Confirm actual generated config if available; configuration source alone is insufficient.
verified=0
while IFS= read -r -d '' cfg; do
  if grep -q '^CONFIG_KSU=y$' "$cfg"; then
    echo "CONFIRMED CONFIG_KSU=y: $cfg" | tee -a build-verification.txt
    verified=1
    break
  fi
done < <(find out bazel-bin dist -type f \( -name '.config' -o -name 'config' \) -print0 2>/dev/null || true)

if [[ "$verified" != 1 ]]; then
  echo 'WARNING: Generated CONFIG_KSU=y not independently verified; do not flash.' \
    | tee -a build-verification.txt
fi
sha256sum dist/Image* | tee -a build-verification.txt
ls -lh dist/Image* | tee -a build-verification.txt
