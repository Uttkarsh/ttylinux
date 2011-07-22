#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is as follows:
#
# Copyright (C) 2010-2010 Douglas Jerome <douglas@ttylinux.org>
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
#	This script attempts to download the ttylinux source packages.
#
# CHANGE LOG
#
#	16nov10	drj	Miscellaneous fussing.
#	01apr10	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# dload_get_file
# *****************************************************************************

# Usage: dload_get_file <filename> <tag> <url> [url ...]

dload_get_file() {

local fileName="$1"
local fileTag="$2"
local loadedDn="no"
local url

shift
shift

pushd "pkg-src" >/dev/null 2>&1

trap "rm -f ${fileName}.${fileTag}" EXIT

echo -n "i> Checking ${fileName} " 
for ((i=(25-${#fileName}) ; i > 0 ; i--)); do echo -n "."; done
rm -f "${fileName}.download.log"

# Maybe the file doesn't get downloaded.
#
if [[ x"${fileTag}" = x"(cross-tools)" ]]; then
	echo " (comes from cross-tools)" 
	popd >/dev/null 2>&1
	return 0
fi
if [[ x"${fileTag}" = x"(local)" ]]; then
	echo " (local)" 
	popd >/dev/null 2>&1
	return 0
fi

# If the file is already in pkg-src/ then return.
#
if [[ -f "${fileName}.${fileTag}" ]]; then
	echo " have it" 
	popd >/dev/null 2>&1
	return 0
fi

echo -n " downloading ..... "

# See if there is a local copy of the file.
#
if [[ -f "${K_CACHEDIR}/${fileName}.${fileTag}" ]]; then
	cp "${K_CACHEDIR}/${fileName}.${fileTag}" .
	echo "(got from local cache)."
	popd >/dev/null 2>&1
	return 0
fi

# See if there is a program to use to download the file.
#
_wget=$(which wget 2>/dev/null || true)
if [[ -z "${_wget}" ]]; then
	echo "cannot find wget-- no download."
	popd >/dev/null 2>&1
	unset _wget
	return 0
fi
_wget="${_wget} -T 15 -nc --progress=dot:binary --tries=3"
_file=""

# Try to download the file from the urls.
#
rm -f "${fileName}.download.log"
>"${fileName}.download.log"
for url in "$@"; do
	_file="${url}/${fileName}.${fileTag}"
	if [[ "${loadedDn}" = "no" ]]; then
		(${_wget} --passive-ftp "${_file}" \
		|| ${_wget} "${_file}" \
		|| true) >>"${fileName}.download.log" 2>&1
		if [[ -f "${fileName}.${fileTag}" ]]; then
			loadedDn="yes"
		fi
	fi
done
unset _wget
unset _file

if [[ "${loadedDn}" = "yes" ]]; then
	echo "done"
	rm -f "${fileName}.download.log"
	chmod 600 ${fileName}.${fileTag}
else
	echo "FAILED"
fi

popd >/dev/null 2>&1

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

K_CACHEDIR=$DOWNLOAD_CACHE_DIR

dist_config_setup || exit 1


# *****************************************************************************
# Main Program
# *****************************************************************************

pListF="packages-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.txt"
pkgFile="${TTYLINUX_PLATFORM_DIR}/${pListF}"

egrep -v "^[[:space:]]*(#|$)" ${pkgFile} | while read name pad tag url; do
	dload_get_file ${name} ${tag} "${url}"
done

unset pkgFile
unset pListF

# TTYLINUX_LOADER unbound variable
#case ${TTYLINUX_LOADER%%-*} in
#	lilo)
#		dload_get_file ${TTYLINUX_LOADER} tar.gz "http://alioth.debian.org/frs/download.php/3309/"
#		;;
#	yaboot)
#		dload_get_file ${TTYLINUX_LOADER} tar.gz "http://yaboot.ozlabs.org/releases/"
#		;;
#	*) ;;
#esac


# *****************************************************************************
# Exit with Status
# *****************************************************************************

exit $?


# end of file
