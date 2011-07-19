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
#	This script has general startup and functions.
#
# CHANGE LOG
#
#	03mar11	drj	Added TTYLINUX_TAR_NAME
#	21jan11	drj	Conditional "ws-" prefix for the IMG and ISO file names.
#	06jan11	drj	Added TTYLINUX_SITE_DIR
#	01jan11	drj	Updated for TTYLINUX_CLASS, ttylinux-config.sh changes.
#	15dec10	drj	Updated to get package list from new file name.
#	11dec10	drj	Added comments.
#	11dec10	drj	Made build_config_setup() more specific.
#	11dec10	drj	Changed to use new platform directory structure.
#	16nov10	drj	Miscellaneous fussing.
#	08oct10	drj	Minor simplifications.
#	02apr10	drj	Did organizational changes for the embedded systems.
#	05mar10	drj	Removed ttylinux.site-config.sh
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Check script environment.
# *****************************************************************************

dist_root_check() {

if [[ $(id -u) -ne 0 ]]; then
	echo "E> Only root can do this (scary)." >&2
	return 1
fi

if [[ $(id -g) -ne 0 ]]; then
	echo "E> Must be in the root group, not the $(id -gn) group." >&2
	echo "E> Try using 'newgrp - root'." >&2
	return 1
fi

return 0

}


# *****************************************************************************
# Check the distribution specifications.
# *****************************************************************************

dist_config_setup() {

# This functions sets:
#
# TTYLINUX_BUILD_DIR
# TTYLINUX_CONFIG_DIR
# TTYLINUX_DOC_DIR
# TTYLINUX_IMG_DIR
# TTYLINUX_MNT_DIR
# TTYLINUX_PKGBIN_DIR
# TTYLINUX_PKGBLD_DIR
# TTYLINUX_PKGCFG_DIR
# TTYLINUX_PKGSRC_DIR
# TTYLINUX_SCRIPT_DIR
# TTYLINUX_SITE_DIR
# TTYLINUX_VAR_DIR
# TTYLINUX_IMG_NAME
# TTYLINUX_IRD_NAME
# TTYLINUX_TAR_NAME
# TTYLINUX_ISO_NAME
# TTYLINUX_PLATFORM_DIR
# TTYLINUX_PACKAGES

# This function uses:
#
# These come from the ttylinux-config.sh file:
#
# TTYLINUX_CPU .......... must have a value
# TTYLINUX_VERSION ...... must have a value
# TTYLINUX_DIR .......... must have a value
# TTYLINUX_PLATFORM ..... must have a value
# TTYLINUX_CLASS ........ must have a value

local imageTag
local pListFile

# Create environment variables for the ttylinux directories and files.
#
imageTag="${TTYLINUX_CPU}-${TTYLINUX_VERSION}"
TTYLINUX_BUILD_DIR="${TTYLINUX_DIR}/build-root"
TTYLINUX_CONFIG_DIR="${TTYLINUX_DIR}/config"
TTYLINUX_DOC_DIR="${TTYLINUX_DIR}/doc"
TTYLINUX_IMG_DIR="${TTYLINUX_DIR}/img"
TTYLINUX_MNT_DIR="${TTYLINUX_DIR}/mnt"
TTYLINUX_PKGBIN_DIR="${TTYLINUX_DIR}/pkg-bin"
TTYLINUX_PKGBLD_DIR="${TTYLINUX_DIR}/pkg-bld"
TTYLINUX_PKGCFG_DIR="${TTYLINUX_DIR}/pkg-cfg"
TTYLINUX_PKGSRC_DIR="${TTYLINUX_DIR}/pkg-src"
TTYLINUX_SCRIPT_DIR="${TTYLINUX_DIR}/scripts"
TTYLINUX_SITE_DIR="${TTYLINUX_DIR}/site"
TTYLINUX_VAR_DIR="${TTYLINUX_DIR}/var"
case ${TTYLINUX_CLASS} in
	"em" )
	TTYLINUX_IMG_NAME="${TTYLINUX_DIR}/img/em-file_sys-${imageTag}.img"
	TTYLINUX_IRD_NAME="${TTYLINUX_DIR}/img/em-initrd-${imageTag}"
	TTYLINUX_TAR_NAME="${TTYLINUX_DIR}/img/em-ttylinux-${imageTag}.tar.bz2"
	TTYLINUX_ISO_NAME="${TTYLINUX_DIR}/img/em-ttylinux-${imageTag}.iso"
	;;
	"sm" )
	TTYLINUX_IMG_NAME="${TTYLINUX_DIR}/img/file_sys-${imageTag}.img"
	TTYLINUX_IRD_NAME="${TTYLINUX_DIR}/img/initrd-${imageTag}"
	TTYLINUX_TAR_NAME="${TTYLINUX_DIR}/img/ttylinux-${imageTag}.tar.bz2"
	TTYLINUX_ISO_NAME="${TTYLINUX_DIR}/img/ttylinux-${imageTag}.iso"
	;;
	"ut" )
	TTYLINUX_IMG_NAME="${TTYLINUX_DIR}/img/ut-file_sys-${imageTag}.img"
	TTYLINUX_IRD_NAME="${TTYLINUX_DIR}/img/ut-initrd-${imageTag}"
	TTYLINUX_TAR_NAME="${TTYLINUX_DIR}/img/ut-ttylinux-${imageTag}.tar.bz2"
	TTYLINUX_ISO_NAME="${TTYLINUX_DIR}/img/ut-ttylinux-${imageTag}.iso"
	;;
	"ws" )
	TTYLINUX_IMG_NAME="${TTYLINUX_DIR}/img/ws-file_sys-${imageTag}.img"
	TTYLINUX_IRD_NAME="${TTYLINUX_DIR}/img/ws-initrd-${imageTag}"
	TTYLINUX_TAR_NAME="${TTYLINUX_DIR}/img/ws-ttylinux-${imageTag}.tar.bz2"
	TTYLINUX_ISO_NAME="${TTYLINUX_DIR}/img/ws-ttylinux-${imageTag}.iso"
	;;
esac
#
TTYLINUX_PLATFORM_DIR="${TTYLINUX_CONFIG_DIR}/platform-${TTYLINUX_PLATFORM}"
if [[ ! -d "${TTYLINUX_PLATFORM_DIR}" ]]; then
	echo "E> Cannot find platform directory." >&2
	echo "=> config/<platform>" >&2
	return 1
fi

# Get the list of packages or exit with an error.
#
pListFile="packages-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.txt"
if [[ ! -f ${TTYLINUX_PLATFORM_DIR}/${pListFile} ]]; then
	echo "E> Cannot find package list file." >&2
	echo "=> ${TTYLINUX_PLATFORM_DIR}/${pListFile}" >&2
	return 1
fi
TTYLINUX_PACKAGES=$(awk \
	'/^[     ]*[\#$]/ {next}; {print $1}' \
	${TTYLINUX_PLATFORM_DIR}/${pListFile})

return 0

}


# *****************************************************************************
# Check the distribution specifications.
# *****************************************************************************

build_config_setup() {

# This functions sets:
#
# TTYLINUX_XTOOL_DIR = ${XBT_DIR}/${TTYLINUX_XBT}
# XBT_LINUX_ARCH ...... set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_LINUX_VER ....... set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_LIBC_VER ........ set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_XBINUTILS_VER ... set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_XGCC_VER ........ set from ${TTYLINUX_XTOOL_DIR}/_versions

local dcount=0
local err=0
local xtooldir=""

# Check if the initial environmental variables are set.
#
if [[ -z "${XBT_DIR}" ]]; then
	# From ttylinux-config.sh
	echo "E> No cross-tools directory is specified." >&2
	err=1
fi

# Check for the cross-tool chain and load the cross-tool components' versions,
# if they can be found.  Set the cross-tool directory variable,
# TTYLINUX_XTOOL_DIR, here.
#
set +u
xtooldir="${XBT_DIR}/${TTYLINUX_XBT}"
if [[ ! -d "${xtooldir}" ]]; then
	echo "E> ${TTYLINUX_XBT} cross-tool chain not found." >&2
	return 1
fi
if [[ ! -f "${xtooldir}/_versions" ]]; then
	echo "E> ${TTYLINUX_XBT} cross-tool chain is broken." >&2
	echo "E> no ${xtooldir}/_versions file" >&2
	return 1
fi
TTYLINUX_XTOOL_DIR=${xtooldir}
source "${TTYLINUX_XTOOL_DIR}/_versions"
[[ -z "${XBT_LINUX_ARCH}"    ]] && err=1
[[ -z "${XBT_LINUX_VER}"     ]] && err=1
[[ -z "${XBT_LIBC_VER}"      ]] && err=1
[[ -z "${XBT_XBINUTILS_VER}" ]] && err=1
[[ -z "${XBT_XGCC_VER}"      ]] && err=1
if [[ ${err} -eq 1 ]]; then
	echo "E> Error in ${TTYLINUX_XTOOL_DIR}/_versions." >&2
	return 1
fi
set -u

return 0

}


# *****************************************************************************
# Mount the target filesystem.
# *****************************************************************************

build_spec_show() {

# Report on what we think we are doing.
#
echo "=> ttylinux project directory:"
echo "   ${TTYLINUX_DIR}"
echo "=> ${TTYLINUX_CLASS} ttylinux-${TTYLINUX_VERSION} [${TTYLINUX_NAME}]"
echo "=> with ${TTYLINUX_CPU} cross-building Binutils ${XBT_XBINUTILS_VER}"
echo "=> with ${TTYLINUX_CPU} cross-building GCC ${XBT_XGCC_VER}"
echo "=> with libc ${XBT_LIBC_VER}, kernel interface:"
echo "        libc interface to Linux kernel ${XBT_LINUX_ARCH} architecture"
echo "        libc interface to Linux kernel ${XBT_LINUX_VER}"
echo "=> for ${TTYLINUX_FSI_SIZE} MB target file system image size"

return 0

}


# *****************************************************************************
# Mount the target filesystem.
# *****************************************************************************

ttylinux_target_mount() {

if [[ -n "$(mount | grep \"${TTYLINUX_IMG_NAME}\")" ]]; then
        echo "E> Already mounted." >&2
        echo "E> ${TTYLINUX_IMG_NAME}" >&2
        return 0
fi

set +e
echo -n "Mounting ..... "
mount -t ext2 -o loop ${TTYLINUX_IMG_NAME} ${TTYLINUX_MNT_DIR}
[[ $? -eq 0 ]] && echo "OK" || echo "FAILED"
set -e

return 0

}


# *****************************************************************************
# Unmount the target filesystem.
# *****************************************************************************

ttylinux_target_umount() {

set +e
echo -n "Unmounting ... "
umount -d ${TTYLINUX_MNT_DIR}
[[ $? -eq 0 ]] && echo "OK" || echo "FAILED"
set -e

return 0

}


# *************************************************************************** #
#                                                                             #
# _ f u n c t i o n s   B o d y                                               #
#                                                                             #
# *************************************************************************** #

K_TB=$'\t'
K_NL=$'\n'
K_SP=$' '

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.

export IFS="${K_SP}${K_TB}${K_NL}"
export LC_ALL=POSIX
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

umask 022


# end of file
