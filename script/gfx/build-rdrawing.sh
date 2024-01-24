#!/bin/bash

set -euxo pipefail

rdrawing_dir="$_BUILDDIR/$_RDRAWING_DIR"
[[ -d "$rdrawing_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_RDRAWING_ARCHIVE"
cd "$rdrawing_dir"
for harch in $_LLVM_ARCHES; do
  cp src/{rdrawing,rturtle}.h "$_BUILDDIR/$harch/llvm-mingw/include"
done

cat <<EOF >>src/CMakeLists.txt
add_dependencies(rturtle rdrawing)
target_link_libraries(rdrawing PUBLIC raylib)
target_link_libraries(rturtle PUBLIC rdrawing)
EOF

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet-static"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DBUILD_SHARED_LIBS=OFF
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir"/src/{librdrawing,librturtle}.a "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done

  [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

  build_dir="build-$triplet-shared"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DBUILD_SHARED_LIBS=ON
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    cp "$build_dir"/src/{librdrawing,librturtle}.dll "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
    cp "$build_dir"/src/{librdrawing,librturtle}.dll.a "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
  done
done
