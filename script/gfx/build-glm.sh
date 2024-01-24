#!/bin/bash

set -euxo pipefail

glm_dir="$_BUILDDIR/$_GLM_DIR"
[[ -d "$glm_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_GLM_ARCHIVE"
cd "$glm_dir"
for harch in $_LLVM_ARCHES; do
  find glm -type f -name "*.h" -exec cp --parents {} "$_BUILDDIR/$harch/llvm-mingw/include" \;
  find glm -type f -name "*.hpp" -exec cp --parents {} "$_BUILDDIR/$harch/llvm-mingw/include" \;
  find glm -type f -name "*.inl" -exec cp --parents {} "$_BUILDDIR/$harch/llvm-mingw/include" \;
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_CXX_COMPILER="$triplet-clang++" -DGLM_TEST_ENABLE=OFF -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir/glm/libglm_static.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib/libglm.a"

    [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

    cp "$build_dir/glm/libglm_shared.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin/libglm.dll"
    cp "$build_dir/glm/libglm_shared.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib/libglm.dll.a"
  done
done
