#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is as follows:
#
# Copyright (C) 2010-2011 Douglas Jerome <douglas@ttylinux.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA


# ******************************************************************************
# Definitions
# ******************************************************************************

PKG_NAME="gcc"
PKG_VERSION="4.5.2"
PKG_BLD_PARTS="gmp-4.3.2 mpfr-2.4.2 mpc-0.8.1"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

cd "${PKG_NAME}-${PKG_VERSION}"

# Suppress the installation of libiberty.a; it is provided by binutils.
#
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in

# Pure 64-bit fixups.
#
if [[ "${TTYLINUX_CPU}" = "x86_64" ]]; then
	# Change GCC to use /lib   for 64-bit stuff, not /lib64
	# Change GCC to use /lib32 for 32-bit stuff, not /lib
	sed -e 's|/lib/ld-linux.so.2|/lib32/ld-linux.so.2|' \
		-i gcc/config/i386/linux64.h
	sed -e 's|/lib64/ld-linux-x86-64.so.2|/lib/ld-linux-x86-64.so.2|' \
		-i gcc/config/i386/linux64.h
	sed -e 's|../lib64|../lib|'   -i gcc/config/i386/t-linux64
	sed -e 's|../lib)|../lib32)|' -i gcc/config/i386/t-linux64
	# On x86_64, unsetting the multilib spec for GCC ensures that it won't
	# attempt to link against libraries on the host.
	for f in $(find gcc/config -name t-linux64) ; do
		sed -e '/MULTILIB_OSDIRNAMES/d' -i "${f}"
	done
	unset f
fi

cd ..

rm --force --recursive "build-gcc"
mkdir "build-gcc"

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local ENABLE_LANGUAGES="--enable-languages=c"
local ENABLE__CXA_ATEXIT=""
local ENABLE_THREADS="--enable-threads=no"

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

for partDir in ${PKG_BLD_PARTS}; do
	case ${partDir} in
		gmp-*)  mv ${partDir} ${PKG_NAME}-${PKG_VERSION}/gmp  ;;
		mpfr-*) mv ${partDir} ${PKG_NAME}-${PKG_VERSION}/mpfr ;;
		mpc-*) mv ${partDir} ${PKG_NAME}-${PKG_VERSION}/mpc ;;
	esac
done
unset partDir

cd "build-gcc"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"

if [[ "${XBT_C_PLUS_PLUS}" = "yes" ]]; then
	ENABLE_LANGUAGES="--enable-languages=c,c++"
	ENABLE__CXA_ATEXIT="--enable-__cxa_atexit"
fi
[[ "${XBT_THREAD_MODEL}" = "nptl" ]] && ENABLE_THREADS="--enable-threads=posix"

AR=${XBT_AR} \
AS=${XBT_AS} \
CC=${XBT_CC} \
CXX=${XBT_CXX} \
LD=${XBT_LD} \
NM=${XBT_NM} \
OBJCOPY=${XBT_OBJCOPY} \
RANLIB=${XBT_RANLIB} \
SIZE=${XBT_SIZE} \
STRIP=${XBT_STRIP} \
CFLAGS="${TTYLINUX_CFLAGS}" \
../${PKG_NAME}-${PKG_VERSION}/configure \
	--build=${MACHTYPE} \
	--host=${XBT_TARGET} \
	--target=${XBT_TARGET} \
	--prefix=/usr \
	--mandir=/usr/share/man \
	${ENABLE_LANGUAGES} \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-long-long \
	--enable-shared \
	--enable-symvers=gnu \
	${ENABLE_THREADS} \
	${ENABLE__CXA_ATEXIT} \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-multilib \
	--disable-nls

source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

cd "build-gcc"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make --jobs=${NJOBS} CROSS_COMPILE=${XBT_TARGET}-
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

cd "build-gcc"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make DESTDIR=${TTYLINUX_BUILD_DIR} install
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TTYLINUX_BUILD_DIR}"
fi

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_clean
# ******************************************************************************

pkg_clean() {
PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"
rm --force --recursive "build-gcc"
PKG_STATUS=""
return 0
}


# end of file
