#!/bin/bash

set -euxo pipefail

raygui_dir="$_BUILDDIR/$_RAYGUI_DIR"
[[ -d "$raygui_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_RAYGUI_ARCHIVE"
cd "$raygui_dir"
for harch in $_LLVM_ARCHES; do
  cp src/raygui.h "$_BUILDDIR/$harch/llvm-mingw/include"
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  mkdir -p "$build_dir"
  {
    pushd "$build_dir"
    $triplet-clang -xc -Os -DNDEBUG -DRAYGUI_IMPLEMENTATION -c -o raygui.o "$raygui_dir/src/raygui.h"
    $triplet-ar rcs libraygui.a raygui.o

    for harch in $_LLVM_ARCHES; do
      cp libraygui.a "$_BUILDDIR/$harch/llvm-mingw/lib"
    done

    [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

    $triplet-clang -xc -Os -DNDEBUG -DRAYGUI_IMPLEMENTATION -DBUILD_LIBTYPE_SHARED -fPIC -shared -o libraygui.dll -Wl,--out-implib,libraygui.dll.a "$raygui_dir/src/raygui.h" -lraylib

    for harch in $_LLVM_ARCHES; do
      cp libraygui.dll "$_BUILDDIR/$harch/llvm-mingw/lib"
      cp libraygui.dll.a "$_BUILDDIR/$harch/llvm-mingw/lib"
    done
    popd
  }
done
