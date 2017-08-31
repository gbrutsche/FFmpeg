#!/bin/bash

function toolchain_name {
    case $CPU in
        arm )
            TOOLCHAIN_NAME=arm-linux-androideabi ;;
        arm64 )
            TOOLCHAIN_NAME=aarch64-linux-android ;;
        x86 )
            TOOLCHAIN_NAME=i686-linux-android ;;
        x86_64 )
            TOOLCHAIN_NAME=x86_64 ;;
    esac
}

function build_one {
    toolchain_name

    TOOLCHAIN=/tmp/ffmpeg
    SYSROOT=$TOOLCHAIN/sysroot/

    rm -rf $TOOLCHAIN

    $ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh --platform=android-$PLATFORM --install-dir=$TOOLCHAIN --arch=$CPU

    PATH=$TOOLCHAIN/bin:$PATH
    CC=$TOOLCHAIN_NAME-gcc
    LD=$TOOLCHAIN_NAME-ld
    AR=$TOOLCHAIN_NAME-ar

    PREFIX=$(pwd)/android/$CPU 

    ./configure --prefix=$PREFIX \
        --enable-shared --disable-static \
        --disable-doc --disable-ffmpeg \
        --disable-ffplay --disable-ffprobe \
        --disable-ffserver --disable-avdevice \
        --disable-doc --disable-symver \
        --cross-prefix=$TOOLCHAIN/bin/$TOOLCHAIN_NAME- \
        --target-os=android --arch=$CPU --enable-cross-compile \
        --sysroot=$SYSROOT --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
        --extra-ldflags="$ADDI_LDFLAGS" $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j $(nproc)
    make install

    find $PREFIX/lib/ -maxdepth 1 -type f | xargs -L 1 $TOOLCHAIN_NAME-strip --strip-unneeded

    rm -rf $TOOLCHAIN
}

CPU=arm
PLATFORM=21
ADDI_CFLAGS="-m$CPU"
build_one
