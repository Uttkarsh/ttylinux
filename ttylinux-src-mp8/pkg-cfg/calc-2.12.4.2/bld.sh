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

PKG_NAME="calc"
PKG_VERSION="2.12.4.2"
PKG_BLD_PARTS=""


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

local BS_BITS="32"

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

if [[ "${TTYLINUX_CPU}" = "x86_64" ]]; then BS_BITS=64; fi

cd "${PKG_NAME}-${PKG_VERSION}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make clobber
PATH="${XBT_BIN_PATH}:${PATH}" make \
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
	calc-static-only \
		BLD_TYPE=calc-static-only \
		INCDIR="${TTYLINUX_XTOOL_DIR}/target/usr/include" \
		LONG_BITS=${BS_BITS}
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

cd "${PKG_NAME}-${PKG_VERSION}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
instCmd="install --owner=root --group=root"
${instCmd} --mode=755 calc-static  "${TTYLINUX_BUILD_DIR}/usr/bin/calc"
${instCmd} --mode=755 --directory  "${TTYLINUX_BUILD_DIR}/usr/share/calc/"
${instCmd} --mode=755 cal/bindings "${TTYLINUX_BUILD_DIR}/usr/share/calc/"
unset instCmd
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
PKG_STATUS=""
return 0
}


# end of file
