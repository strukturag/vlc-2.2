#!/bin/bash
set -eu

if [ -f "/vagrant.env" ]; then
    . /vagrant.env
fi

echo "Performing bootstrap..."

cd vlc
./bootstrap

CONFIGURE_FLAGS=""

function compile {
    ARCH=$1
    if [ "${ARCH}" = "i686" ]; then
        WIN="win32"
    fi
    if [ "${ARCH}" = "x86_64" ]; then
        WIN="win64"
    fi

    echo "Build ${ARCH} version..."
    rm -rf ${WIN}
    mkdir -p ${WIN}
    pushd ${WIN}
    export PKG_CONFIG_LIBDIR=$HOME/vlc/contrib/${ARCH}-w64-mingw32/lib/pkgconfig:$HOME/vlc/contrib/${WIN}/libde265
    eatmydata ../extras/package/win32/configure.sh --host=${ARCH}-w64-mingw32 ${CONFIGURE_FLAGS}
    eatmydata make -j8
    popd
}

compile i686
compile x86_64
