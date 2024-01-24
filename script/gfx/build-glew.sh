#!/bin/bash

set -euxo pipefail

glew_dir="$_BUILDDIR/$_GLEW_DIR"
[[ -d "$glew_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_GLEW_ARCHIVE"
cd "$glew_dir"
for harch in $_LLVM_ARCHES; do
  cp include/GL/{glew,wglew}.h "$_BUILDDIR/$harch/llvm-mingw/include/GL"
done

cd build/cmake
for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DBUILD_UTILS=OFF
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/lib/libglew32.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"

    [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

    cp "$build_dir/bin/glew32.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin/libglew32.dll"
    cp "$build_dir/lib/libglew32.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done
done
