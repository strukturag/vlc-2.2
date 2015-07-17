#!/bin/bash
set -eu

if [ -f "/vagrant.env" ]; then
    . /vagrant.env
fi

PREBUILT_VERSION=20150519

cd vlc

function prepare_dependencies {
    ARCH=$1

    echo "Prepare dependencies for ${ARCH} version..."
    mkdir -p contrib/win32
    pushd contrib/win32
    ../bootstrap --host=${ARCH}-w64-mingw32
    sed -i "s/-latest.tar/-${PREBUILT_VERSION}.tar/g" Makefile
    CACHE_FILE=vlc-contrib-${ARCH}-w64-mingw32-${PREBUILT_VERSION}.tar.bz2
    if [ -f "/vagrant/.cache/${CACHE_FILE}" ]; then
        cp /vagrant/.cache/${CACHE_FILE} .
    fi
    eatmydata make prebuilt
    eatmydata make .libde265 -j8
    if [ ! -f "/vagrant/.cache/${CACHE_FILE}" ]; then
        mkdir -p /vagrant/.cache/
        cp ${CACHE_FILE} /vagrant/.cache/
    fi
    if [ "${ARCH}" = "i686" ]; then
        rm -f ../i686-w64-mingw32/bin/moc ../i686-w64-mingw32/bin/uic ../i686-w64-mingw32/bin/rcc
    fi
    popd
}

prepare_dependencies i686
prepare_dependencies x86_64
