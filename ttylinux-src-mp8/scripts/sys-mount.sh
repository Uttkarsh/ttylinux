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
#	This script loop-mounts the ttylinux root file system image file.
#
# CHANGE LOG
#
#	08oct10	drj	Minor simplifications.
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
# Mount the target image file.
# *****************************************************************************

if [[ $# -eq 1 ]]; then
	[[ x"$1" = x"info" ]] && {
		echo $(basename ${TTYLINUX_IMG_NAME})
		exit 0
	}
fi

ttylinux_target_mount


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
