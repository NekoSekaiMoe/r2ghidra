#!/bin/sh

type fakeroot > /dev/null 2>&1
if [ $? = 0 ]; then
FAKEROOT=fakeroot
else
FAKEROOT=sudo
fi

r2 -qv

if [ $? != 0 ]; then
	# git clone --depth=1 git@github.com:radareorg/radare2 r2 || exit 1
    apt-get update
	apt-get -y install xz-utils git dpkg-dev pkg-config wget binutils git g++ make pkg-config flex bison unzip patch
    wget https://github.com/radareorg/radare2/releases/download/6.1.4/radare2-dev_6.1.4_arm64.deb
	wget https://github.com/radareorg/radare2/releases/download/6.1.4/radare2_6.1.4_arm64.deb
	dpkg -i r2/dist/debian/*/*.deb
fi
[ -z "${DESTDIR}" ] && DESTDIR="/work/dist/debian/root"

RV=`r2 -qv`
[ -z "${RV}" ] && RV=`r2/configure -qV`

R2_LIBR_PLUGINS=`r2 -H R2_LIBR_PLUGINS`
[ -z "${R2_LIBR_PLUGINS}" ] && R2_LIBR_PLUGINS=/usr/lib/radare2

export CFLAGS=-O2
./preconfigure
./configure --prefix=/usr
make R2_PLUGDIR=${R2_LIBR_PLUGINS} DESTDIR=${DESTDIR}

./configure --prefix=/usr
make -j4
strip --strip-unneeded src/core_ghidra.so
${FAKEROOT} make install DESTDIR="${DESTDIR}"
