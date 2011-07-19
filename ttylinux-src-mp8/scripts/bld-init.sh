#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is as follows:
#
# Copyright (C) 2008-2010 Douglas Jerome <douglas@ttylinux.org>
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


# *****************************************************************************
#
# PROGRAM DESCRIPTION
#
#	This script initializes the ttylinux build process.
#
# CHANGE LOG
#
#	15mar11	drj	Added platform boot.cfg support.
#	23jan11	drj	Removed basefs and devfs; these now are packages.
#	08jan11	drj	Added the collecting of glibc i18n data.
#	15dec10	drj	Use new dev node package file name and location.
#	11dec10	drj	Changed for the new platform directory structure.
#	20nov10	drj	Added the separate /dev directory.
#	03mar10	drj	Removed ttylinux.site-config.sh
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# i18n_setup
# *****************************************************************************

i18n_setup() {

local charmap="glibc-charmaps-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.cfg"
local locales="glibc-locales-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.cfg"

build_config_setup || exit 1
source "${TTYLINUX_XTOOL_DIR}/_versions"

if [[ x"${XBT_LIBC_VER:0:6}" = x"glibc-" ]]; then

	echo -n "=> Creating GLIBC i18n charmap configuration ... "
	charmap="${TTYLINUX_PLATFORM_DIR}/${charmap}"
	rm -rf "${charmap}"
	ls -1 "${TTYLINUX_XTOOL_DIR}/target/usr/share/i18n/charmaps/" | \
		sed -e "s/\(.*\)/# \1/" >"${charmap}"
	echo "DONE"

	echo -n "=> Creating GLIBC i18n locales configuration ... "
	locales="${TTYLINUX_PLATFORM_DIR}/${locales}"
	rm -rf "${locales}"
	ls -1 "${TTYLINUX_XTOOL_DIR}/target/usr/share/i18n/locales/" | \
		sed -e "s/\(.*\)/# \1/" >"${locales}"
	echo "DONE"

fi

}


# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Set up the shell functions and environment variables.
# *****************************************************************************

source ./ttylinux-config.sh
source ${TTYLINUX_DIR}/scripts/_functions.sh

dist_root_check   || exit 1
dist_config_setup || exit 1


# *****************************************************************************
# Set up the directory tree used for building ttylinux packages.
# *****************************************************************************

trap "rm --force --recursive ${TTYLINUX_BUILD_DIR}/*" EXIT

echo -n "=> Creating preliminary development build directories ... "
rm --force --recursive "${TTYLINUX_BUILD_DIR}/"*
mkdir --mode=755 "${TTYLINUX_BUILD_DIR}/BUILD"
echo "DONE"

trap - EXIT

if [[ "${TTYLINUX_CLASS}" = "ws" ]]; then i18n_setup; fi

if [[ -f "${TTYLINUX_PLATFORM_DIR}/boot.cfg" ]]; then
	source "${TTYLINUX_PLATFORM_DIR}/boot.cfg"
	_xl=${X_LOAD:-no}
	_ub=${U_BOOT:-no}
	if [[ "${_xl}" != "no" || "${_ub}" != "no" ]]; then
		build_config_setup || exit 1
		(cd ${TTYLINUX_CONFIG_DIR}/bootloader-xload; . ./bld.sh ${_xl})
		(cd ${TTYLINUX_CONFIG_DIR}/bootloader-uboot; . ./bld.sh ${_ub})
	fi
	unset _xl
	unset _ub
fi


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
