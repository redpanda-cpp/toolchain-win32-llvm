#!/bin/bash

set -euxo pipefail

utf8_dir="$_BUILDDIR/utf8"
mkdir -p "$utf8_dir"
cd "$utf8_dir"

for tarch in $_LLVM_ARCHES; do
  triplet="$tarch-w64-mingw32"

  build_dir="build-$triplet"
  mkdir -p "$build_dir"
  {
    pushd "$build_dir"
    $triplet-clang -Os -fno-exceptions -nodefaultlibs -nostdlib -c -o "utf8init.o" "$_SRCDIR/src/utf8/utf8init.cpp"
    $triplet-windres -O coff -o "utf8manifest.o" "$_SRCDIR/src/utf8/utf8manifest.rc"

    for harch in $_LLVM_ARCHES; do
      cp "utf8init.o" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
      cp "utf8manifest.o" "$_BUILDDIR/$harch/llvm-mingw/$triplet/lib"
    done
    popd
  }

  msvc_triplet="$tarch-pc-windows-msvc"
  build_dir="build-$msvc_triplet"
  mkdir -p "$build_dir"
  {
    pushd "$build_dir"
    $triplet-clang -target $msvc_triplet -Os -fno-exceptions -nodefaultlibs -nostdlib -c -o "utf8init.o" "$_SRCDIR/src/utf8/utf8init.cpp"
    $triplet-windres -O coff -o "utf8manifest.o" "$_SRCDIR/src/utf8/utf8manifest.rc"

    for harch in $_LLVM_ARCHES; do
      mkdir -p "$_BUILDDIR/$harch/llvm-mingw/$msvc_triplet/lib"
      cp "utf8init.o" "$_BUILDDIR/$harch/llvm-mingw/$msvc_triplet/lib"
      cp "utf8manifest.o" "$_BUILDDIR/$harch/llvm-mingw/$msvc_triplet/lib"
    done
    popd
  }
done

[[ "$_ENABLE_ARM64EC" -eq 0 ]] && exit 0

{
  triplet=x86_64-w64-mingw32
  msvc_triplet=arm64ec-pc-windows-msvc
  build_dir="build-$msvc_triplet"
  mkdir -p "$build_dir"
  {
    pushd "$build_dir"
    $triplet-clang -target $msvc_triplet -Os -fno-exceptions -nodefaultlibs -nostdlib -c -o "utf8init.o" "$_SRCDIR/src/utf8/utf8init.cpp"
    $triplet-windres -O coff -o "utf8manifest.o" "$_SRCDIR/src/utf8/utf8manifest.rc"

    for harch in $_LLVM_ARCHES; do
      mkdir -p "$_BUILDDIR/$harch/llvm-mingw/$msvc_triplet/lib"
      cp "utf8init.o" "$_BUILDDIR/$harch/llvm-mingw/$msvc_triplet/lib"
      cp "utf8manifest.o" "$_BUILDDIR/$harch/llvm-mingw/$msvc_triplet/lib"
    done
    popd
  }
}
