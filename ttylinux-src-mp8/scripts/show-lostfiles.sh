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
#	This script lists the files in build-root that are not in a package
#	list.  The package lists are in build-root/usr/share/ttylinux.
#
# CHANGE LOG
#
#	13jan11	drj	File creation.
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

# dist_config_setup || exit 1


# *****************************************************************************
# Main Program
# *****************************************************************************

hit=0
hitList=""
f=""
p=""

for f in $(find build-root/ -type f); do
	f=${f#build-root/}
	[[ "${f:0:19}" == "usr/share/ttylinux/" ]] && continue || true
	hit=0
	hitList=""
	for p in $(ls build-root/usr/share/ttylinux/*-FILES); do
		grep "^${f}\>" ${p} >/dev/null 2>&1 && {
			hit=$((${hit} + 1))
			hitList+="${p} "
		} || true
	done
	case ${hit} in
		0)	echo "=> Lost file \"${f}\"" ;;
		1)	;;
		*)	echo "=> Multiply-claimed file \"${f}\""
			for p in ${hitList}; do
				echo "   $(basename ${p})"
			done
			;;
	esac
done

unset hit
unset hitList
unset f
unset p


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
