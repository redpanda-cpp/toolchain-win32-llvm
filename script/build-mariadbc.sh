#!/bin/bash

set -euxo pipefail

mariadbc_dir="$_BUILDDIR/$_MARIADBC_DIR"
[[ -d "$mariadbc_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_MARIADBC_ARCHIVE"
cd "$mariadbc_dir"

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  pkg_dir="pkg-$triplet"
  cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE="MinSizeRel" -DCMAKE_SYSTEM_NAME="Windows" -DCMAKE_C_COMPILER="$triplet-clang" -DWITH_UNIT_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$triplet"
  cmake --build "$build_dir" --parallel

  for harch in $_LLVM_ARCHES; do
    mkdir -p "$_BUILDDIR/$harch/llvm-mingw/$triplet/include"

    cmake --install "$build_dir" --prefix "$pkg_dir"
    cp -r "$pkg_dir/include/mariadb" "$_BUILDDIR/$harch/llvm-mingw/$triplet/include"
    cp -r "$pkg_dir/include/mariadb" "$_BUILDDIR/$harch/llvm-mingw/$triplet/include/mysql"
    cp "$pkg_dir/lib/mariadb/libmariadbclient.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
    cp "$pkg_dir/lib/mariadb/libmariadbclient.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib/libmysqlclient.a"

    [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

    cp "$pkg_dir/lib/mariadb/libmariadb.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
    cp "$pkg_dir/lib/mariadb/libmariadb.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin/libmysql.dll"
    cp "$pkg_dir/lib/mariadb/liblibmariadb.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib/libmariadb.dll.a"
    cp "$pkg_dir/lib/mariadb/liblibmariadb.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib/libmysql.dll.a"
    cp -r "$pkg_dir/lib/mariadb/plugin" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
  done
done
