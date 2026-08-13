#!/usr/bin/env bash
set -euo pipefail

./configure --prefix="$USED_PREFIX" \
--target="$TOOLCHAIN" \
--disable-examples \
--disable-unit-tests \
--disable-tools \
--disable-docs \
--enable-static-msvcrt \
--enable-vp8 \
--enable-vp9 \
--enable-webm-io \
--size-limit=4096x4096

# libvpx generates two projects that write the same ASM object files. Building
# them concurrently corrupts those files on current GitHub Windows runners.
sed -i 's/msbuild.exe vpx.sln -m/msbuild.exe vpx.sln/g' Makefile
if grep -Fq 'msbuild.exe vpx.sln -m' Makefile; then
    echo 'Failed to serialize libvpx MSBuild invocation.' >&2
    exit 1
fi

make -j1
make -j1 install
