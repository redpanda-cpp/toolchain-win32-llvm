#!/bin/bash

set -euxo pipefail

raylib_dir="$_BUILDDIR/$_RAYLIB_DIR"
[[ -d "$raylib_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_RAYLIB_ARCHIVE"
cd "$raylib_dir"
for harch in $_LLVM_ARCHES; do
  cp src/{raylib,raymath,rlgl}.h "$_BUILDDIR/$harch/llvm-mingw/include"
done
cp src/{raylib,raymath,rlgl}.h "$_BUILDDIR/host/llvm-mingw/generic-w64-mingw32/include"

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet-static"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DOPENGL_VERSION="3.3" -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/raylib/libraylib.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done

  [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

  build_dir="build-$triplet-shared"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DOPENGL_VERSION="3.3" -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=ON
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/raylib/libraylib.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
    cp "$build_dir/raylib/libraylib.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done
  cp "$build_dir/raylib/libraylib.dll" "$_BUILDDIR/host/llvm-mingw/$triplet/bin"
  cp "$build_dir/raylib/libraylib.dll.a" "$_BUILDDIR/host/llvm-mingw/$triplet/lib"
done
