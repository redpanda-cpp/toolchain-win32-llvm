#!/bin/bash

set -euxo pipefail

export LLVM_MINGW_TAG="20231128"
export REDPANDA_RELEASE="17-r0"

export FMT_VERSION="10.2.1"
export SQLITE_RELEASE_YEAR="2024"
export SQLITE_VERSIONID="3450000"
export MARIADBC_VERSION="3.3.8"
export TINYFILEDIALOGS_COMMIT="865c1c84bc824aa8fa5fd46f3a51a8c56fe237b4"

export GLM_VERSION="0.9.9.8"
export FREEGLUT_VERSION="3.4.0"
export GLFW_VERSION="3.3.9"
export GLEW_VERSION="2.2.0"
export RAYLIB_VERSION="4.5.0"
export RAYGUI_VERSION="3.6"
export RDRAWING_COMMIT="d032dfa84b48fc5b7da7c672fbface081b6930e4"

_LLVM_HOST_DIR="llvm-mingw-$LLVM_MINGW_TAG-ucrt-ubuntu-20.04-x86_64"
_LLVM_HOST_ARCHIVE="$_LLVM_HOST_DIR.tar.xz"
_LLVM_HOST_URL="https://github.com/mstorsjo/llvm-mingw/releases/download/$LLVM_MINGW_TAG/$_LLVM_HOST_ARCHIVE"
export _LLVM_ARCHES="x86_64 i686 aarch64"

function llvm-dir() {
  local arch="$1"
  echo "llvm-mingw-$LLVM_MINGW_TAG-ucrt-$arch"
}
function llvm-archive() {
  local arch="$1"
  echo "$(llvm-dir "$arch").zip"
}
function llvm-url() {
  local arch="$1"
  echo "https://github.com/mstorsjo/llvm-mingw/releases/download/$LLVM_MINGW_TAG/$(llvm-archive "$arch")"
}

export _CLEAN=0
export _ENABLE_ARM64EC=0
export _ENABLE_SHARED=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean)
      _CLEAN=1
      shift
      ;;
    --enable-arm64ec)
      _ENABLE_ARM64EC=1
      shift
      ;;
    --enable-shared)
      _ENABLE_SHARED=1
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

export _FMT_DIR="fmt-$FMT_VERSION"
export _FMT_ARCHIVE="$_FMT_DIR.zip"
_FMT_URL="https://github.com/fmtlib/fmt/releases/download/$FMT_VERSION/$_FMT_ARCHIVE"

export _SQLITE_DIR="sqlite-amalgamation-$SQLITE_VERSIONID"
export _SQLITE_ARCHIVE="$_SQLITE_DIR.zip"
_SQLITE_URL="https://www.sqlite.org/$SQLITE_RELEASE_YEAR/$_SQLITE_ARCHIVE"

export _MARIADBC_DIR="mariadb-connector-c-$MARIADBC_VERSION"
export _MARIADBC_ARCHIVE="$_MARIADBC_DIR.tar.gz"
_MARIADBC_URL="https://github.com/mariadb-corporation/mariadb-connector-c/archive/refs/tags/v$MARIADBC_VERSION.tar.gz"

export _TINYFILEDIALOGS_DIR="tinyfiledialogs-$TINYFILEDIALOGS_COMMIT"
export _TINYFILEDIALOGS_REPO="tinyfiledialogs.git"
_TINYFILEDIALOGS_URL="https://git.code.sf.net/p/tinyfiledialogs/code"

export _GLM_DIR="glm"
export _GLM_ARCHIVE="glm-$GLM_VERSION.7z"
_GLM_URL="https://github.com/g-truc/glm/releases/download/$GLM_VERSION/$_GLM_ARCHIVE"

export _FREEGLUT_DIR="freeglut-$FREEGLUT_VERSION"
export _FREEGLUT_ARCHIVE="$_FREEGLUT_DIR.tar.gz"
_FREEGLUT_URL="https://github.com/freeglut/freeglut/releases/download/v$FREEGLUT_VERSION/$_FREEGLUT_ARCHIVE"

export _GLFW_DIR="glfw-$GLFW_VERSION"
export _GLFW_ARCHIVE="$_GLFW_DIR.zip"
_GLFW_URL="https://github.com/glfw/glfw/releases/download/$GLFW_VERSION/$_GLFW_ARCHIVE"

export _GLEW_DIR="glew-$GLEW_VERSION"
export _GLEW_ARCHIVE="$_GLEW_DIR.tgz"
_GLEW_URL="https://github.com/nigels-com/glew/releases/download/glew-$GLEW_VERSION/$_GLEW_ARCHIVE"

export _RAYLIB_DIR="raylib-$RAYLIB_VERSION"
export _RAYLIB_ARCHIVE="$_RAYLIB_DIR.tar.gz"
_RAYLIB_URL="https://github.com/raysan5/raylib/archive/refs/tags/$RAYLIB_VERSION.tar.gz"

export _RAYGUI_DIR="raygui-$RAYGUI_VERSION"
export _RAYGUI_ARCHIVE="$_RAYGUI_DIR.tar.gz"
_RAYGUI_URL="https://github.com/raysan5/raygui/archive/refs/tags/$RAYGUI_VERSION.tar.gz"

export _RDRAWING_DIR="raylib-drawing-$RDRAWING_COMMIT"
export _RDRAWING_ARCHIVE="$_RDRAWING_DIR.tar.gz"
_RDRAWING_URL="https://github.com/royqh1979/raylib-drawing/archive/$RDRAWING_COMMIT.tar.gz"

export _SRCDIR="$PWD"
export _ASSETSDIR="$PWD/assets"
export _BUILDDIR="$PWD/build"
export _DISTDIR="$PWD/dist"

function prepare-dirs() {
  if [[ $_CLEAN -eq 1 ]]; then
    rm -rf "$_BUILDDIR"
    rm -rf "$_DISTDIR"
  fi
  mkdir -p "$_ASSETSDIR" "$_BUILDDIR" "$_DISTDIR"
}

function download-llvm() {
  [[ -f "$_ASSETSDIR/$_LLVM_HOST_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_LLVM_HOST_ARCHIVE" "$_LLVM_HOST_URL"
  for arch in $_LLVM_ARCHES; do
    [[ -f "$_ASSETSDIR/$(llvm-archive "$arch")" ]] || curl -L -o "$_ASSETSDIR/$(llvm-archive "$arch")" "$(llvm-url "$arch")"
  done
}

function download-assets() {
  [[ -f "$_ASSETSDIR/$_FMT_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_FMT_ARCHIVE" "$_FMT_URL"
  [[ -f "$_ASSETSDIR/$_SQLITE_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_SQLITE_ARCHIVE" "$_SQLITE_URL"
  [[ -f "$_ASSETSDIR/$_MARIADBC_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_MARIADBC_ARCHIVE" "$_MARIADBC_URL"
  {
    [[ -d "$_ASSETSDIR/$_TINYFILEDIALOGS_REPO" ]] || git clone --bare "$_TINYFILEDIALOGS_URL" "$_ASSETSDIR/$_TINYFILEDIALOGS_REPO"
    pushd "$_ASSETSDIR/$_TINYFILEDIALOGS_REPO"
    git fetch --all
    popd
  }
  [[ -f "$_ASSETSDIR/$_GLM_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_GLM_ARCHIVE" "$_GLM_URL"
  [[ -f "$_ASSETSDIR/$_FREEGLUT_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_FREEGLUT_ARCHIVE" "$_FREEGLUT_URL"
  [[ -f "$_ASSETSDIR/$_GLFW_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_GLFW_ARCHIVE" "$_GLFW_URL"
  [[ -f "$_ASSETSDIR/$_GLEW_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_GLEW_ARCHIVE" "$_GLEW_URL"
  [[ -f "$_ASSETSDIR/$_RAYLIB_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_RAYLIB_ARCHIVE" "$_RAYLIB_URL"
  [[ -f "$_ASSETSDIR/$_RAYGUI_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_RAYGUI_ARCHIVE" "$_RAYGUI_URL"
  [[ -f "$_ASSETSDIR/$_RDRAWING_ARCHIVE" ]] || curl -L -o "$_ASSETSDIR/$_RDRAWING_ARCHIVE" "$_RDRAWING_URL"
}

function extract-llvm() {
  pushd "$_BUILDDIR"
  mkdir -p host
  [[ -d "$_BUILDDIR/host/llvm-mingw" ]] || (bsdtar -xf "$_ASSETSDIR/$_LLVM_HOST_ARCHIVE" && mv "$_LLVM_HOST_DIR" host/llvm-mingw)
  for arch in $_LLVM_ARCHES; do
    mkdir -p "$arch"
    [[ -d "$_BUILDDIR/$arch/llvm-mingw" ]] || (
      bsdtar -xf "$_ASSETSDIR/$(llvm-archive "$arch")" && \
      mv "$(llvm-dir "$arch")" "$arch/llvm-mingw" && \
      rm -rf "$arch/llvm-mingw/armv7-w64-mingw32" && \
      rm -rf "$arch"/llvm-mingw/bin/armv7-w64-mingw32-*
    )
  done
  popd
}

function package-llvm() {
  for arch in $_LLVM_ARCHES; do
    pushd "$_BUILDDIR/$arch"
    local archive="$_DISTDIR/llvm-mingw-$REDPANDA_RELEASE-$arch.7z"
    [[ -f "$archive" ]] && rm -f "$archive"
    7z a -t7z -mx=9 -ms=on -mqs=on -mf="BCJ2" -m0="LZMA2:d=64m:fb=273:c=1g" "$archive" llvm-mingw &
    popd
  done
  wait
}

prepare-dirs
download-llvm
download-assets
extract-llvm
export PATH="$_BUILDDIR/host/llvm-mingw/bin:$PATH"

./script/build-utf8.sh
./script/build-fmt.sh
./script/build-sqlite.sh
./script/build-mariadbc.sh
./script/build-tinyfiledialogs.sh

./script/gfx/build-glm.sh
./script/gfx/build-freeglut.sh
./script/gfx/build-glfw.sh
./script/gfx/build-glew.sh
./script/gfx/build-raylib.sh
./script/gfx/build-raygui.sh
./script/gfx/build-rdrawing.sh

package-llvm
