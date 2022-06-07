#! /bin/bash

################################################################################
# This script only needs running if an older version of binutils is installed. #
################################################################################

git clone --depth 1 git://sourceware.org/git/binutils-gdb.git
cd binutils-gdb
./configure --target x86_64-w64-mingw32
make
make install
