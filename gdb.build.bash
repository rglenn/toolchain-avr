#!/bin/bash -ex

if [[ ! -d toolsdir  ]] ;
then
	echo "You must first build the tools: run build_tools.bash"
	exit 1
fi

cd toolsdir/bin
TOOLS_BIN_PATH=`pwd`
cd -

export PATH="$TOOLS_BIN_PATH:$PATH"

if [[ ! -f gdb-7.7.tar.bz2  ]] ;
then
	wget http://mirror.switch.ch/ftp/mirror/gnu/gdb/gdb-7.7.tar.bz2
fi

tar xfjv gdb-7.7.tar.bz2

cd gdb-7.7
for p in ../gdb-patches/*.patch; do echo Applying $p; patch -p1 < $p; done
cd -

mkdir -p objdir
cd objdir
PREFIX=`pwd`
cd -

mkdir -p gdb-build
cd gdb-build

CONFARGS=" \
	--prefix=$PREFIX \
	--disable-nls \
	--disable-werror \
	--target=avr"

CFLAGS="-w -O2 -g0 $CFLAGS" CXXFLAGS="-w -O2 -g0 $CXXFLAGS" LDFLAGS="-s $LDFLAGS" ../gdb-7.7/configure $CONFARGS

if [ -z "$MAKE_JOBS" ]; then
	MAKE_JOBS="2"
fi

nice -n 10 make -j $MAKE_JOBS

make install

