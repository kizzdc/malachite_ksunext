#!/usr/bin/env bash
set -euo pipefail

# Pin GKI to the kernel commit reported by malachite:
# 6.1.78-android14-11-gb6577b760481-ab12075023
GKI_TAG='android14-6.1-2024-06_r4'
EXPECTED_PREFIX='b6577b760481'
KSU_TAG='v3.4.2'

mkdir -p gki
cd gki
repo init -u https://android.googlesource.com/kernel/manifest \
  -b common-android14-6.1 --depth=1
repo sync -c -j4 --no-tags --fail-fast

git -C common fetch --depth=1 https://android.googlesource.com/kernel/common \
  "refs/tags/${GKI_TAG}"
git -C common checkout --detach FETCH_HEAD
ACTUAL="$(git -C common rev-parse HEAD)"
if [[ "$ACTUAL" != "$EXPECTED_PREFIX"* ]]; then
  echo "ERROR: Expected GKI $EXPECTED_PREFIX but got $ACTUAL" >&2
  exit 2
fi

curl -fsSL "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/${KSU_TAG}/kernel/setup.sh" \
  -o /tmp/malachite-ksunext-setup.sh
bash /tmp/malachite-ksunext-setup.sh "$KSU_TAG"

DEFCONFIG=common/arch/arm64/configs/gki_defconfig
test -f "$DEFCONFIG" || { echo "ERROR: Missing $DEFCONFIG" >&2; exit 3; }
# CONFIG_KSU is "default y" in KernelSU Next Kconfig once dependencies are met.
# Explicitly adding it to gki_defconfig makes Bazel's savedefconfig check fail.
# Preserve the existing minimal defconfig and let Kconfig select KernelSU.
common/scripts/config --file "$DEFCONFIG" -e KPROBES -e EXT4_FS
test -L common/drivers/kernelsu || { echo 'ERROR: KSU source symlink missing'; exit 4; }
grep -Fq 'source "drivers/kernelsu/Kconfig"' common/drivers/Kconfig || {
  echo 'ERROR: KernelSU Kconfig was not sourced'; exit 5;
}
grep -q 'default y' common/drivers/kernelsu/Kconfig || {
  echo 'ERROR: KernelSU default-y condition not found'; exit 6;
}
# Verify the effective .config (CONFIG_KSU=y) after building.

cat > build-verification.txt <<EOF
Device: malachite / HyperOS 1 / Android 14
GKI tag: $GKI_TAG
GKI commit: $ACTUAL
KernelSU Next: $KSU_TAG
KernelSU commit: $(git -C KernelSU-Next rev-parse HEAD)
Integration: built-in (CONFIG_KSU=y), experimental
SUSFS: disabled
Not flashable by itself: output kernel Image must be repacked and validated.
EOF
cat build-verification.txt
