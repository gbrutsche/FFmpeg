#!/bin/bash

PLATFORM=21

function toolchain_name {
    case $CPU in
        arm )
            TOOLCHAIN_NAME=arm-linux-androideabi ;;
        arm64 )
            TOOLCHAIN_NAME=aarch64-linux-android ;;
    esac
}

function build_one {
    toolchain_name

    SYSROOT=$ANDROID_NDK_HOME/platforms/android-$PLATFORM/arch-$CPU/
    TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/$TOOLCHAIN_NAME-4.9/prebuilt/linux-x86_64

    PATH=$TOOLCHAIN/bin:$PATH
    CC=arm-linux-androideabi-gcc
    LD=arm-linux-androideabi-ld
    AR=arm-linux-androideabi-ar

    PREFIX=$(pwd)/android/$CPU 

    ./configure --prefix=$PREFIX \
        --enable-shared --disable-static \
        --disable-doc --disable-ffmpeg \
        --disable-ffplay --disable-ffprobe \
        --disable-avdevice \
        --disable-doc --disable-symver \
        --cross-prefix=$TOOLCHAIN/bin/$TOOLCHAIN_NAME- \
        --target-os=android --arch=$CPU --enable-cross-compile \
        --sysroot=$SYSROOT --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
        --extra-ldflags="$ADDI_LDFLAGS" $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j $(nproc)
    make install

    find $PREFIX/lib/ -maxdepth 1 -type f | xargs -L 1 $TOOLCHAIN_NAME-strip --strip-unneeded
}

CPU=arm
ADDI_CFLAGS="-marm"
build_one
