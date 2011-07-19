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
#	This script lists the packages for the currently selected build.
#
# CHANGE LOG
#
#	09oct10	drj	Minor simplifications.
#	04mar10	drj	Removed ttylinux.site-config.sh and handle glibc-*.
#	19jul09	drj	File creation.
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

dist_config_setup || exit 1


# *****************************************************************************
# Main Program
# *****************************************************************************

if [[ -z "${TTYLINUX_PACKAGES}" ]]; then
	echo "E> No packages.  How did you do that\?" >&2
	exit 1
fi

echo "i> ${TTYLINUX_CPU}-${TTYLINUX_PLATFORM} ttylinux ${TTYLINUX_VERSION} packages:"
for p in ${TTYLINUX_PACKAGES}; do
	echo "${p}"
done


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
