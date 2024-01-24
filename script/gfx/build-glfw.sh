#!/bin/bash

set -euxo pipefail

glfw_dir="$_BUILDDIR/$_GLFW_DIR"
[[ -d "$glfw_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_GLFW_ARCHIVE"
cd "$glfw_dir"
for harch in $_LLVM_ARCHES; do
  cp -r include/GLFW "$_BUILDDIR/$harch/llvm-mingw/include"
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet-static"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -DBUILD_SHARED_LIBS=OFF
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/src/libglfw3.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done

  [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

  build_dir="build-$triplet-shared"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -DBUILD_SHARED_LIBS=ON
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/src/glfw3.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin/libglfw3.dll"
    cp "$build_dir/src/libglfw3dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib/libglfw3.dll.a"
  done
done
