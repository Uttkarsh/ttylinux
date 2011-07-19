#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is as follows:
#
# Copyright (C) 2008-2011 Douglas Jerome <douglas@ttylinux.org>
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
#	This script runs the busybox configuration process for the ttylinux
#	busybox using the existing ttylinux busybox configuration.  The new
#	configuration file is put in the top-level ttylinux directory.
#
# CHANGE LOG
#
#	14mar11	drj	Put busybox config file in top-level ttylinux directory.
#	16feb11	drj	Put busybox config file back in config directory.
#	22dec10	drj	Change build directory to temporary directory in var.
#	13nov10	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Try to clean up.
# *****************************************************************************

bail_out() {

rm --force --recursive ${K_BLD_DIR}

}


# *****************************************************************************
# Configure busybox.
# *****************************************************************************

busybox_config() {

local bbpkg=""
local bbname="bbox-$1-${TTYLINUX_CLASS}"
local bbcfg="${TTYLINUX_CONFIG_DIR}/${bbname}.cfg"
local srcd="${TTYLINUX_PKGSRC_DIR}"

echo "i> Regenerate a busybox configuration file:"
echo "=> ${TTYLINUX_TARGET_TAG}"
echo "=> ${bbname}.cfg"

# Look for the busybox tarball name in the package list.
#
for p in ${TTYLINUX_PACKAGES}; do
	[[ x"${p:0:8}" = x"busybox-" ]] && bbpkg=${p} || true
done; unset p
if [[ -z "${bbpkg}" ]]; then
	echo "E> Busybox package name not found in the package list." >&2
	exit 1
fi

# Look for the busybox tarball.
#
if [[ ! -f "${TTYLINUX_PKGSRC_DIR}/${bbpkg}.tar.bz2" ]]; then
	echo "E> Busybox source tarball not found." >&2
	echo "=> ${TTYLINUX_PKGSRC_DIR}/${bbpkg}.tar.bz2" >&2
	exit 1
fi

# Look for the busybox configuration file.
#
if [[ ! -f "${bbcfg}" ]]; then
	echo "w> Busybox configuration file not found." >&2
	echo "=> ${bbcfg}" >&2
	: # ?? exit 1
fi

trap bail_out EXIT

# Uncompress, untarr then remove ${bbpkg}.tar.bz2.
#
echo -n "I> Getting and uncompressing ${bbpkg}.tar.bz2 ..."
rm --force --recursive ${bbpkg}*
cp "${TTYLINUX_PKGSRC_DIR}/${bbpkg}.tar.bz2" "${bbpkg}.tar.bz2"
bunzip2 --force "${bbpkg}.tar.bz2"
tar --extract --file="${bbpkg}.tar"
rm --force "${bbpkg}.tar"
echo "DONE"

# Make a busybox configuration, starting with the current configuration if
# there is one.
#
echo ""
echo "Save your busybox configuration file as \".config\" and it will be"
echo "renamed and copied to the ttylinux directory."
echo "=> ${TTYLINUX_DIR}"
echo ""
echo "I> make menuconfig"
echo -n "Hit <enter> to continue: "
read
[[ -f "${bbcfg}" ]] && cp "${bbcfg}" "${bbpkg}/.config" || true
cd "${bbpkg}"
TERM=xterm-color make menuconfig
cd ..

# If there is a new configuration file with the standard name, then move an
# old busybox configuration file to a backup and move the new configuration
# file into its place.
#
if [[ -f "${bbpkg}/.config" ]]; then
	newCfgFile="${TTYLINUX_DIR}/${bbname}.cfg"
	if [[ -f "${newCfgFile}" ]]; then
		fver="00"
		oldCfgFile="${TTYLINUX_DIR}/${bbname}-${fver}.cfg"
		while [[ -f "${oldCfgFile}"  ]]; do
			fver=$((${fver} + 1))
			[[ ${fver} -lt 10 ]] && fver="0${fver}" || true
			oldCfgFile="${TTYLINUX_DIR}/${bbname}-${fver}.cfg"
		done
		echo -e "i> Making backup of busybox config file."
		echo -e "=> was: ${newCfgFile}"
		echo -e "=> now: ${oldCfgFile}"
		mv "${newCfgFile}" "${oldCfgFile}"
		unset fver
		unset oldCfgFile
	fi
	mv "${bbpkg}/.config" "${newCfgFile}"
	chmod 600 "${bbcfg}"
	echo ""
	echo -e "i> New busybox config file is ready."
	echo -e "=> \e[32m${newCfgFile}\e[0m"
	echo ""
	echo -e "To use the new busybox configuration file, copy it to the"
	echo -e "config directory:"
	echo -e "=> ${TTYLINUX_CONFIG_DIR}"
	echo ""
	unset newCfgFile
fi

trap - EXIT

rm --force --recursive ${K_BLD_DIR}

return 0

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

dist_config_setup  || exit 1
build_config_setup || exit 1


# *****************************************************************************
# Main Program
# *****************************************************************************

K_BLD_DIR=$(mktemp --directory ${TTYLINUX_VAR_DIR}/tmp.XXXXXXXX 2>/dev/null)
if [[ $? != 0 ]]; then
	echo "E> Cannot make temporary directory." >&2
	echo "=> Maybe install mktemp" >&2
	exit 1
fi

pushd "${K_BLD_DIR}" >/dev/null 2>&1
[[ x"$1" = x"stnd" ]] && busybox_config stnd || true
[[ x"$1" = x"suid" ]] && busybox_config suid || true
popd >/dev/null 2>&1

unset K_BLD_DIR

echo ""
echo "##### DONE cross-configuring a busybox config file."


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
