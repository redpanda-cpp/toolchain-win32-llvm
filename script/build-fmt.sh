#!/bin/bash

set -euxo pipefail

fmt_dir="$_BUILDDIR/$_FMT_DIR"
[[ -d "$fmt_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_FMT_ARCHIVE"
cd "$fmt_dir"
for harch in $_LLVM_ARCHES; do
  cp -r include/fmt "$_BUILDDIR/$harch/llvm-mingw/include"
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet-static"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_CXX_COMPILER="$triplet-clang++" -DFMT_TEST=OFF -DBUILD_SHARED_LIBS=OFF
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/libfmt.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done

  [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

  build_dir="build-$triplet-shared"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_CXX_COMPILER="$triplet-clang++" -DFMT_TEST=OFF -DBUILD_SHARED_LIBS=ON
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/bin/libfmt.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
    cp "$build_dir/libfmt.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done
done
