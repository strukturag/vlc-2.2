#!/bin/bash

# This script enforces statically linking of libgcc, libstdc++-6, and libpthread,
# without needing to rebuild gcc and mingw-w64 from scratch.
# -static-libgcc -static-libstdc++ flags can not be used in a libtool build system,
# as libtool removes flags that it doesn't understand.

move() {
    [ -f $1 ] || return 1
    mkdir -p old/
    mv -v $* old/
    return 0
}

for x in i686 x86_64
do
    library_path_list=`$x-w64-mingw32-gcc -v /dev/null 2>&1 | grep ^LIBRARY_PATH|cut -d= -f2|sort|uniq`
    IFS=':'
    for i in $library_path_list
    do
        cd $i
        move libstdc++-6.dll libstdc++.dll.a libgcc_s.a libgcc_s_sjlj-1.dll && ln -s libgcc_eh.a libgcc_s.a
        move libpthread.dll.a libwinpthread.dll.a
        move libwinpthread-1.dll
        [ -d ../bin ] && cd ../bin && move libwinpthread-1.dll
    done
done

exit 0
