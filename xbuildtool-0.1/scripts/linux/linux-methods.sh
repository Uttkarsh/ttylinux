#!/bin/bash


# This file is NOT part of the kegel-initiated cross-tools software.
# This file is NOT part of the crosstool-NG software.
# This file IS part of the ttylinux xbuildtool software.
# The license which this software falls under is as follows:
#
# Copyright (C) 2007-2011 Douglas Jerome <douglas@ttylinux.org>
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
# FILE NAME
#
#	$RCSfile:$
#	$Revision:$
#	$Date:$
#
# PROGRAM INFORMATION
#
#	Developed by:	xbuildtools project
#	Developer:	Douglas Jerome, drj, <douglas@ttylinux.org>
#
# FILE DESCRIPTION
#
#	This script builds the cross-development Linux header files.
#
# CHANGE LOG
#
#	01jan11	drj	Initial version from ttylinux cross-tools.
#
# *****************************************************************************


# *****************************************************************************
# xbt_resolve_linux_name
# *****************************************************************************

# Usage: xbt_resolve_linux_name <string>
#
# Uses:
#      XBT_SCRIPT_DIR
#
# Sets:
#     XBT_LINUX
#     XBT_LINUX_MD5SUM
#     XBT_LINUX_URL

xbt_resolve_linux_name() {

source ${XBT_SCRIPT_DIR}/linux/linux-versions.sh

XBT_LINUX=""
XBT_LINUX_MD5SUM=""
XBT_LINUX_URL=""

for (( i=0 ; i<${#_LINUX[@]} ; i=(($i+1)) )); do
	if [[ "${1}" = "${_LINUX[$i]}" ]]; then
		XBT_LINUX="${_LINUX[$i]}"
		XBT_LINUX_MD5SUM="${_LINUX_MD5SUM[$i]}"
		XBT_LINUX_URL="${_LINUX_URL[$i]}"
		i=${#_LINUX[@]}
	fi
done

unset _LINUX
unset _LINUX_MD5SUM
unset _LINUX_URL

if [[ -z "${XBT_LINUX}" ]]; then
	echo "E> Cannot resolve \"${1}\""
	return 1
fi

return 0

}


# *****************************************************************************
# xbt_build_kernel_headers
# *****************************************************************************

# When building GLIBC for Linux it is best to have the Linux kernel header
# files available; the programming interface to the Linux kernel typically is
# through functions provided by GLIBC, and GLIBC needs the kernel header files
# to properly provide this interface.  This is the same for UCLIBC.
#
# The Linux source distribution has a build process that can be used to export
# and install its user interface header files.  The files that are already at
# the destination directory of the export and install of the Linux kernel user
# interface header files will be deleted: this optional part of the Linux build
# process is rude.

xbt_build_kernel_headers() {

local msg

msg="Getting ${XBT_LINUX} Headers "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_35 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_LINUX}.  The second argument is a secondary
# location to copy the source code tarball; this is so that users of the cross
# tool chain have access to the Linux source code as any users likely will
# cross-build the Linux kernel.
#
xbt_src_get ${XBT_LINUX} "${XBT_TARGET_DIR}/../_pkg-src"

if [[ -d "${XBT_LINUX}" && ! -d "linux" ]]; then
	ln -s "${XBT_LINUX}" "linux"
fi
cd linux

for p in ${XBT_PATCH_DIR}/${XBT_LINUX}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p

echo "Exporting ${XBT_LINUX_ARCH} kernel header files (${XBT_TARGET})."
make \
	ARCH=${XBT_LINUX_ARCH} \
	INSTALL_HDR_PATH="${XBT_XTARG_DIR}/usr" \
	headers_install

# Clean up.
#
cd ..
rm -rf "linux"
rm -rf "${XBT_LINUX}"

echo "done" >&${CONSOLE_FD}

return 0

}


# end of file
