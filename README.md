# Windows LLVM Toolchain for Red Panda C++

Based on [LLVM MinGW](https://github.com/mstorsjo/llvm-mingw), with useful libs for beginners.

## Usage

FOR PACKAGERS, NOT FOR END USERS.

This toolchain heavily depends on [compiler hint add-on interface](https://github.com/royqh1979/RedPanda-CPP/blob/master/docs/addon.md). See the implementation ([source](https://github.com/royqh1979/RedPanda-CPP/blob/master/addon/compiler_hint/windows_llvm.tl) or [compiled](https://github.com/royqh1979/RedPanda-CPP/blob/master/packages/msys/compiler_hint.lua)) of Windows LLVM package for example.

## Build

On Ubuntu 20.04 or later:

1. Install `curl`, `git`, `libarchive-tools`, `p7zip`.
2. Run `./build.sh`

Args:

- `--clean`: Clean build directory before build.
- `--enable-arm64ec`: Build `utf8init.o` and `utf8manifest.o` for `arm64ec-pc-windows-msvc` target.
- `--enable-shared`: Build shared libraries.
