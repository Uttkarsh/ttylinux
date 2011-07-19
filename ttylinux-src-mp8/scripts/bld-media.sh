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
#	This script invokes the platform-specific script that puts the ttylinux
#	bootable files onto appropriate media.
#
# CHANGE LOG
#
#	04mar11	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Nada
# *****************************************************************************

nada() {

echo "i> No media method for ${TTYLINUX_PLATFORM}."
return 0

}


# *****************************************************************************
# Write Boot Files to an CD-ROM
# *****************************************************************************

cd_burn() {

echo ""
cdrecord -v speed=44 dev=1,0,0 -tao -data ${TTYLINUX_ISO_NAME}
echo ""

}


# *****************************************************************************
# Write Boot Files to an SD Card
# *****************************************************************************

sdcard_write() {

local sdCardDev=""
local bd=0
local mounted=1

echo "i> Looking for SD card partition #1."

set +o errexit # # Do not exit on command error.  Let mount and umount fail.
while [[ ${mounted} -ne 0 && ${bd} -lt 8 ]]; do
	_dev="/dev/mmcblk${bd}p1"
	echo "=> checking ${_dev}"
	umount "${_dev}"                            >/dev/null 2>&1
	mount -t vfat "${_dev}" ${TTYLINUX_MNT_DIR} >/dev/null 2>&1
	mounted=$?
	[[ ${mounted} -eq 0 ]] && sdCardDev=${_dev}
	[[ ${mounted} -ne 0 ]] && bd=$((${bd} + 1))
	unset _dev
done
set -o errexit # # Exit on command error.

if [[ -z "${sdCardDev}" ]]; then
	echo "E> Cannot find an appropriate SD card paritition."
	return 0
fi

echo ""
echo "Using: ${sdCardDev}"
echo ""

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Deleting files from the media ......... "
rm -rf ${TTYLINUX_MNT_DIR}/*
echo "DONE"

ls --color -ahil ${TTYLINUX_MNT_DIR} | sort
echo ""

echo -n "i> Copying the boot files to the media ... "
cp sdcard/boot/MLO        ${TTYLINUX_MNT_DIR}/MLO
cp sdcard/boot/u-boot.bin ${TTYLINUX_MNT_DIR}/u-boot.bin
cp sdcard/boot/uImage     ${TTYLINUX_MNT_DIR}/uImage
cp sdcard/boot/ramdisk.gz ${TTYLINUX_MNT_DIR}/ramdisk.gz
cp sdcard/boot/boot.scr   ${TTYLINUX_MNT_DIR}/boot.scr
cp sdcard/boot/user.scr   ${TTYLINUX_MNT_DIR}/user.scr
echo "DONE"

ls --color -hil ${TTYLINUX_MNT_DIR} | sort

popd >/dev/null 2>&1

echo ""
echo "i> Unmounting the SD Card."
umount "${sdCardDev}"

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

dist_root_check    || exit 1
dist_config_setup  || exit 1


# *****************************************************************************
# Main Program
# *****************************************************************************

echo ""
echo "##### START making the boot file system image"
echo ""

[[ "${TTYLINUX_PLATFORM}" = "beagle_xm"     ]] && sdcard_write || true
[[ "${TTYLINUX_PLATFORM}" = "integrator_cp" ]] && nada         || true
[[ "${TTYLINUX_PLATFORM}" = "malta_lv"      ]] && nada         || true
[[ "${TTYLINUX_PLATFORM}" = "wrtu54g_tm"    ]] && nada         || true
[[ "${TTYLINUX_PLATFORM}" = "macintosh_g4"  ]] && cd_burn      || true
[[ "${TTYLINUX_PLATFORM}" = "pc"            ]] && cd_burn      || true

echo ""
echo "##### DONE making the boot file system image"
echo ""


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
