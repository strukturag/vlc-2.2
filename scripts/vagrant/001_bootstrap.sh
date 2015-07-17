#!/bin/bash
set -eu

# switch to German mirrors
sed 's/http:\/\/archive/http:\/\/de.archive/g' -i /etc/apt/sources.list

# enable "multiverse" repository
sed 's/ universe$/ universe multiverse/g' -i /etc/apt/sources.list

# setup proxy to apt-cacher (if available)
if [ -f "/vagrant/scripts/vagrant/apt-cacher.conf" ]; then
    cp /vagrant/scripts/vagrant/apt-cacher.conf /etc/apt/apt.conf.d/01proxy
fi

# enable i386 architecture (required for wine)
dpkg --add-architecture i386
sed 's/deb http/deb [arch=amd64,i386] http/g' -i /etc/apt/sources.list

# "accept" the mscorefonts eula
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

# update package information
apt-get -y update

# install basic requirements
if [ ! -x "/usr/bin/eatmydata" ]; then
    apt-get -y install eatmydata
fi
eatmydata apt-get -y install git ccache

# setup ccache
CCACHE_DIR=/vagrant/.ccache
if [ ! -d ${CCACHE_DIR} ]; then
    mkdir -p ${CCACHE_DIR}; \
    CCACHE_DIR=/vagrant/.ccache /usr/bin/ccache --max-size=4G;
    chown -R vagrant:vagrant ${CCACHE_DIR};
fi
if ! grep -q CCACHE_DIR /etc/environment ; then
    echo "CCACHE_DIR=${CCACHE_DIR}" >> /etc/environment ;
fi
if ! grep -q CCACHE_COMPRESS /etc/environment ; then
    echo "CCACHE_COMPRESS=1" >> /etc/environment ;
fi
if ! grep -q CCACHE_COMPILERCHECK /etc/environment ; then
    echo "CCACHE_COMPILERCHECK=content" >> /etc/environment ;
fi
sed 's/PATH="\/usr\/local/PATH="\/usr\/lib\/ccache:\/usr\/local/g' -i /etc/environment

# create file that can be sourced by other scripts to setup environment
if [ ! -f "/vagrant.env" ]; then
    for line in $( cat /etc/environment ) ; do echo "export $line" >> /vagrant.env ; done
fi

# install build requirements
PACKAGES="\
    autoconf \
    libtool \
    gettext \
    nsis \
    p7zip-full \
    dos2unix \
    subversion \
    qt4-dev-tools \
    wine-dev \
    gcc-mingw-w64-i686 \
    g++-mingw-w64-i686 \
    mingw-w64-tools \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64-x86-64 \
    mingw-w64-tools"

echo "Installing packages..."
eatmydata apt-get -y install ${PACKAGES}

# make sure all compilers are linked through ccache
/usr/sbin/update-ccache-symlinks

echo "Prepare for static linking..."
/vagrant/scripts/vagrant/prepare_static_linking.sh
