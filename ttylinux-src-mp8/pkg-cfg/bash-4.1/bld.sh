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

PKG_NAME="bash"
PKG_VERSION="4.1"
PKG_BLD_PARTS=""


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${TTYLINUX_PKGCFG_DIR}/${PKG_NAME}-${PKG_VERSION}/patch"
local patchFile=""

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

cd "${PKG_NAME}-${PKG_VERSION}"
for patchFile in "${patchDir}"/*; do
	[[ -r "${patchFile}" ]] && patch -p0 <"${patchFile}"
done
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local LIB_NCURSES=""
local TERMCAP_LIB="gnutermcap"

PKG_STATUS="Unspecified error -- check the ${PKG_NAME} build log"

if [[ "${TTYLINUX_CLASS}" = "ut" || "${TTYLINUX_CLASS}" = "ws" ]]; then
	LIB_NCURSES="-L${TTYLINUX_BUILD_DIR}/lib"
	TERMCAP_LIB="libcurses"
fi

cd "${PKG_NAME}-${PKG_VERSION}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
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
LDFLAGS="${LIB_NCURSES}" \
bash_cv_job_control_missing=present \
bash_cv_printf_a_format=yes \
bash_cv_termcap_lib=${TERMCAP_LIB} \
./configure \
	--build=${MACHTYPE} \
	--host=${XBT_TARGET} \
	--prefix=/usr \
	--enable-job-control \
	--disable-nls \
	--without-bash-malloc

# ac_cv_func_setvbuf_reversed=no
# ac_cv_have_decl_sys_siglist=yes
# bash_cv_decl_under_sys_siglist=yes
# bash_cv_func_ctype_nonascii=yes
# bash_cv_func_sigsetjmp=present 
# bash_cv_getcwd_malloc=yes
# bash_cv_job_control_missing=present
# bash_cv_printf_a_format=yes
# bash_cv_sys_named_pipes=present
# bash_cv_termcap_lib=libcurses
# bash_cv_ulimit_maxfds=yes
# bash_cv_unusable_rtsigs=no

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

cd "${PKG_NAME}-${PKG_VERSION}"
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

cd "${PKG_NAME}-${PKG_VERSION}"
install --mode=755 --owner=0 --group=0 bash "${TTYLINUX_BUILD_DIR}/bin"
rm --force "${TTYLINUX_BUILD_DIR}/bin/sh"
ln --force --symbolic bash "${TTYLINUX_BUILD_DIR}/bin/sh"
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
