#!/bin/bash

set -euxo pipefail

tinyfiledialogs_dir="$_BUILDDIR/tinyfiledialogs"
if [[ ! -d "$tinyfiledialogs_dir" ]]; then
  mkdir -p "$tinyfiledialogs_dir"
  pushd "$_ASSETSDIR/$_TINYFILEDIALOGS_REPO"
  git --work-tree="$tinyfiledialogs_dir" checkout -f "$TINYFILEDIALOGS_COMMIT"
  popd
fi
cd "$tinyfiledialogs_dir"
for harch in $_LLVM_ARCHES; do
  cp tinyfiledialogs.h more_dialogs/tinyfd_moredialogs.h "$_BUILDDIR/$harch/llvm-mingw/include"
done

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  mkdir -p "$build_dir"
  {
    pushd "$build_dir"
    $triplet-clang -Os -DNDEBUG -I"$tinyfiledialogs_dir" -c -o tinyfiledialogs.o "$tinyfiledialogs_dir/tinyfiledialogs.c"
    $triplet-clang -Os -DNDEBUG -I"$tinyfiledialogs_dir" -c -o tinyfd_moredialogs.o "$tinyfiledialogs_dir/more_dialogs/tinyfd_moredialogs.c"
    $triplet-ar rcs libtinyfiledialogs.a tinyfiledialogs.o tinyfd_moredialogs.o

    for harch in $_LLVM_ARCHES; do
      cp "libtinyfiledialogs.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
    done

    [[ "$_ENABLE_SHARED" -eq 0 ]] && continue

    $triplet-clang -Os -DNDEBUG -I"$tinyfiledialogs_dir" -fPIC -shared -o libtinyfiledialogs.dll -Wl,--out-implib,libtinyfiledialogs.dll.a "$tinyfiledialogs_dir/tinyfiledialogs.c" "$tinyfiledialogs_dir/more_dialogs/tinyfd_moredialogs.c" -lcomdlg32 -lole32

    for harch in $_LLVM_ARCHES; do
      cp "libtinyfiledialogs.dll" "$_BUILDDIR/$harch/llvm-mingw/$triplet/bin"
      cp "libtinyfiledialogs.dll.a" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
    done

    popd
  }
done
