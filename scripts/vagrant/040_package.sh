#!/bin/bash
set -eu

if [ -f "/vagrant.env" ]; then
    . /vagrant.env
fi

cd vlc

NOW=`date +%Y%m%d-%H%M%S`

function package {
    WIN=$1

    echo "Build ${WIN} installer..."
    pushd ${WIN}
    eatmydata make fetch-npapi
    (cd npapi-vlc && git submodule init && git submodule update )
    eatmydata make package-win32 -j8

    mkdir -p /vagrant/build_result/${NOW}
    cp *-${WIN}* /vagrant/build_result/${NOW}/
    popd
}

package win32
package win64

echo "Done, packages have been copied to build_result/${NOW}"
