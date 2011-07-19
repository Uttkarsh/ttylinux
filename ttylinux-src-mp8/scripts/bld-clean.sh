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
#	This script removes and cleans up the ttylinux built items.
#
# CHANGE LOG
#
#	01mar11	drj	Added cleanup in bootloaders that use it.
#	15dec10	drj	Use new clean strategy with $1 = all, kernel, packages.
#	16nov10	drj	Miscellaneous fussing.
#	08oct10	drj	Minor simplifications.
#	03mar10	drj	Removed ttylinux.site-config.sh; added parameter "all".
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
#
# *****************************************************************************

# none


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
# Remove the build.
# *****************************************************************************

# Cleaning any part of the build invalidates any images and the CD-ROM staging
# area, so always remove these.
#
echo "=> Removing file system image, boot CD image, SDCard image."
rm --force --recursive ${TTYLINUX_IMG_NAME}
rm --force --recursive ${TTYLINUX_TAR_NAME}
rm --force --recursive ${TTYLINUX_ISO_NAME}
#
echo "=> Removing boot CD-ROM, SD Card staging areas."
rm --force --recursive ${TTYLINUX_CONFIG_DIR}/cdrom
rm --force --recursive ${TTYLINUX_CONFIG_DIR}/sdcard

# Remove the kernel.
#
if [[ $# -gt 0 ]]; then
	[[ x"$1" = x"all" || x"$1" = x"kernel" ]] && {
		echo "=> Removing kernel and module tree, if any."
		rm --force --recursive ${TTYLINUX_CONFIG_DIR}/kroot
		echo "=> Removing kernel modules package, if any."
		rm --force --recursive ${TTYLINUX_CONFIG_DIR}/kpkgs
	}
fi

# Remove the packages.
#
if [[ $# -gt 0 ]]; then
	[[ x"$1" = x"all" || x"$1" = x"packages" ]] && {
		echo "=> Removing the packages:"
		echo "   -> Removing build-root/ contents."
		rm --force --recursive ${TTYLINUX_BUILD_DIR}/*
		echo "   -> Removing pkg-bin/ binary packages."
		rm --force --recursive ${TTYLINUX_PKGBIN_DIR}/*
		echo "   -> Removing var/log/ build logs."
		rm --force --recursive ${TTYLINUX_VAR_DIR}/log/*
	}
fi

# Remove general stuff, not package or kernel stuff.
#
if [[ $# -gt 0 ]]; then
	[[ x"$1" = x"all" ]] && {
		for _dir in ${TTYLINUX_CONFIG_DIR}/bootloader-*; do
			if [[ -d ${_dir} ]]; then
				(
				cd ${_dir}
				[[ -f ./bld-clean.sh ]] && . ./bld-clean.sh
				)
			fi
		done
		unset _dir
	}
fi


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
