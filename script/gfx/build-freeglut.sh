#!/bin/bash

set -euxo pipefail

freeglut_dir="$_BUILDDIR/$_FREEGLUT_DIR"
[[ -d "$freeglut_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_FREEGLUT_ARCHIVE"
cd "$freeglut_dir"
for harch in $_LLVM_ARCHES; do
  cp -r include/GL "$_BUILDDIR/$harch/llvm-mingw/include"
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DFREEGLUT_BUILD_SHARED_LIBS=ON -DFREEGLUT_BUILD_STATIC_LIBS=ON -DFREEGLUT_BUILD_DEMOS=OFF
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/lib/libfreeglut_static.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"

    # always install the shared library, as freeglut has different interface for static and shared
    cp "$build_dir/bin/libfreeglut.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
    cp "$build_dir/lib/libfreeglut.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done
done
