#!/bin/bash

set -euxo pipefail

sqlite_dir="$_BUILDDIR/$_SQLITE_DIR"
[[ -d "$sqlite_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_SQLITE_ARCHIVE"
cd "$sqlite_dir"
for harch in $_LLVM_ARCHES; do
  cp sqlite3.h "$_BUILDDIR/$harch/llvm-mingw/include"
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  mkdir -p "$build_dir"
  {
    pushd "$build_dir"
    $triplet-clang -Os -DNDEBUG -c -o sqlite3.o "$sqlite_dir/sqlite3.c"
    $triplet-ar rcs libsqlite3.a sqlite3.o 

    for harch in $_LLVM_ARCHES; do
      cp "libsqlite3.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
    done

    [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

    $triplet-clang -Os -DNDEBUG -fPIC -shared -o libsqlite3.dll -Wl,--out-implib,libsqlite3.dll.a "$sqlite_dir/sqlite3.c"

    for harch in $_LLVM_ARCHES; do
      cp "libsqlite3.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
      cp "libsqlite3.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
    done
    popd
  }
done
