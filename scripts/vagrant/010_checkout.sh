#!/bin/bash
set -eu

if [ -f "/vagrant.env" ]; then
    . /vagrant.env
fi

# start from scratch (we are using ccache to speed up compilation)
rm -rf vlc
mkdir -p vlc
cd vlc

echo "Copy contents of git repository..."
( cd /vagrant && git archive --format=tar HEAD ) | tar xf -
cp -rf /vagrant/.git .
