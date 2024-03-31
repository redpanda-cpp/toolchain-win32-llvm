#!/bin/bash

set -euxo pipefail

glm_dir="$_BUILDDIR/$_GLM_DIR"
[[ -d "$glm_dir" ]] || bsdtar -C "$_BUILDDIR" -xf "$_ASSETSDIR/$_GLM_ARCHIVE"
cd "$glm_dir"
for harch in $_LLVM_ARCHES; do
  mkdir -p "$_BUILDDIR/$harch/llvm-mingw/include/glm"
  cp -r $(ls . | grep -v CMakeLists.txt) "$_BUILDDIR/$harch/llvm-mingw/include/glm"
done
