#!/usr/bin/env bash
#
# Copyright (C) 2020 Edwiin Kusuma Jaya (MWG_Ryzen)
#
# Simple Local Kernel Build Script
#
# Configured for Redmi Note 8 / ginkgo custom kernel source
#
# Setup build env with akhilnarang/scripts repo
#
# Use this script on root of kernel directory

sudo ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
bold=$(tput bold)
normal=$(tput sgr0)

# Scrip option
while (( ${#} )); do
    case ${1} in
        "-Z"|"--zip") ZIP=true ;;
    esac
    shift
done

[[ -z ${ZIP} ]] && { echo "${bold}Gunakan -Z atau --zip Untuk Membuat Zip Kernel Installer${normal}"; }

# ENV
CONFIG=vince-perf_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
KERN_IMG="/home/Ryuzen/out-memer/arch/arm64/boot/Image.gz-dtb"
DTBO_IMG="/home/Ryuzen/out-memer/arch/arm64/boot/dtbo.img"
export KBUILD_BUILD_USER="EdwiinKJ"
export KBUILD_BUILD_HOST="RastaMod69"
export PATH="/home/Ryuzen/toolchain/ancient-clang/bin:$PATH"
export LD_LIBRARY_PATH="/home/Ryuzen/toolchain/ancient-clang/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$(/home/Ryuzen/toolchain/ancient-clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export out=/home/Ryuzen/out-memer

# Functions
clang_build () {
    make -j4 O=$out \
                          ARCH=arm64 \
                          CC="clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
					      LD="ld.lld" \
			              AS="llvm-as" \
						  STRIP="llvm-strip" \
			              OBJCOPY="llvm-objcopy" \
			              OBJDUMP="llvm-objdump" \
						  CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=aarch64-linux-gnu-  \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG > /dev/null
echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
clang_build

if ! [ -a $KERN_IMG ]; then
    echo "${bold}Build error, Tolong Perbaiki Masalah Ini${normal}"
    exit 1
fi
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"

[[ -z ${ZIP} ]] && { exit; }

# clone AnyKernel3
if ! [ -d "AnyKernel3" ]; then
    git clone https://github.com/kutemeikito/AnyKernel3
else
    echo "${bold}Direktori AnyKernel3 Sudah Ada, Tidak Perlu di Clone${normal}"
fi

# ENV
ZIP_DIR=$KERNEL_DIR/AnyKernel3
VENDOR_MODULEDIR="$ZIP_DIR/modules/vendor/lib/modules"
STRIP="aarch64-linux-gnu-strip"

# Make zip
make -C "$ZIP_DIR" clean
wifi_modules
cp "$KERN_IMG" "$DTBO_IMG" "$ZIP_DIR"/
make -C "$ZIP_DIR" normal
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
