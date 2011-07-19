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
#	This script makes the ttylinux kernel.
#
# CHANGE LOG
#
#	15mar11	drj	Added BeagleBoard xM kernel build target.
#	12feb11	drj	Added kernel version to the kmodule package file name.
#	01jan11	drj	Added TTYLINUX_CLASS to kernel configuration file name.
#	22dec10	drj	Added support for building mips kernels.
#	15dec10	drj	Use new kernel module package file name and location.
#	11dec10	drj	Changed for the new platform directory structure.
#	16nov10	drj	Added kernel module building.
#	15nov10	drj	Added fixup for the getline() in scripts/unifdef.c
#	13nov10	drj	Removed all RTAI support.
#	09oct10	drj	Minor simplifications.
#	22aug10	drj	Added RTAI kernel patch suport.
#	27jul10	drj	Fixed the TTYLINUX_KERNEL usage in kernel_xbuild().
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
# Try to clean up.
# *****************************************************************************

kernel_clean() {

local kver=${TTYLINUX_KERNEL:-${XBT_LINUX_VER##*-}}

rm --force --recursive ${TTYLINUX_CONFIG_DIR}/kpkgs/
rm --force --recursive ${TTYLINUX_CONFIG_DIR}/kroot/
rm --force --recursive ${TTYLINUX_CONFIG_DIR}/linux-${kver}*/
rm --force --recursive ${TTYLINUX_CONFIG_DIR}/linux/

}


# *****************************************************************************
# Get the kernel source tree and configuration file.
# *****************************************************************************

kernel_get() {

local kver="${TTYLINUX_KERNEL:-${XBT_LINUX_VER##*-}}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"
local srcd="${XBT_DIR}/_pkg-src"

echo -n "g." >&${CONSOLE_FD}

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
fi

# Look for the linux kernel tarball.
#
if [[ ! -f "${srcd}/linux-${kver}.tar.bz2" ]]; then
	echo "E> Linux kernel source tarball not found." >&2
	echo "=> ${srcd}/linux-${kver}.tar.bz2" >&2
	exit 1
fi

# Look for the linux kernel configuration file.
#
if [[ ! -f "${kcfg}" ]]; then
	echo "E> Linux kernel configuration file not found." >&2
	echo "=> ${kcfg}" >&2
	exit 1
fi

_modules=$(set +u; source ${kcfg}; echo "${CONFIG_MODULES}")
[[ x"${_modules}" = x"y" ]] && K_MODULES="yes"
unset _modules
if [[ "${K_MODULES}" = "yes" ]]; then
	echo "i> ##### This kernel configuration has modules."
else
	echo "i> ##### This kernel configuration has NO modules."
fi

# Cleanup any pervious, left-over build results.
#
kernel_clean

# Uncompress, untarr then remove linux-${kver}.tar.bz2 and put the kernel
# configuration file in place.
#
trap kernel_clean EXIT
#
rm --force --recursive linux-${kver}*
cp "${srcd}/linux-${kver}.tar.bz2" "linux-${kver}.tar.bz2"
bunzip2 --force "linux-${kver}.tar.bz2"
tar --extract --file="linux-${kver}.tar"
rm --force "linux-${kver}.tar"
#
cp "${kcfg}" "linux-${kver}/.config"
#
trap - EXIT

}


# *****************************************************************************
# Build the kernel from source and make a binary package.
# *****************************************************************************

kernel_xbuild() {

local kver="${TTYLINUX_KERNEL:-${XBT_LINUX_VER##*-}}"
local bitch=""
local target=""

echo -n "b." >&${CONSOLE_FD}

trap kernel_clean EXIT

# Set ${njobs} to ${ncpus} or 1 if ${ncpus} is undefined, then check for
# non-digits in ${njobs}; if any are found then use the number 1 instead of
# incrementing ${njobs}.  This is the number of jobs to use for make.
#
njobs=${ncpus:-1}
bitch=$(sed --expression="s/[[0-9]]//g" <<<"${njobs}")
[[ -z "${bitch}" ]] && njobs=$((${bitch} + 1)) || njobs=1

# Set the right kernel make target.
case "${TTYLINUX_PLATFORM}-${TTYLINUX_CLASS}" in
	beagle_xm-*)  target="uImage"  ;;
	malta_lv-*)   target="vmlinuz" ;;
	pc-*)         target="bzImage" ;;
	wrtu54g_tm-*) target="vmlinux" ;;
	*-*)          target="zImage"  ;;
esac

cd "linux-${kver}"

# Do some kernel source code fix-ups, if needed.
#
sed --in-place scripts/unifdef.c --expression="s/getline/uc_&/"
sed --in-place scripts/mod/sumversion.c \
	--expression="s|<string.h>| <limits.h>\n#include <string.h>|"
#
_tarFile="${TTYLINUX_PLATFORM_DIR}/kernel-${kver}-add_in.tar.bz2"
if [[ -f ${_tarFile} ]]; then
	echo "Adding-in kernel-${kver}-add_in.tar.bz2"
	tar --extract --file="${_tarFile}"
fi
unset _tarFile
#
for p in ${TTYLINUX_PLATFORM_DIR}/kernel-${kver}-??.patch; do
	if [[ -f "${p}" ]]; then patch -p1 <${p}; fi
done

# Do the kernel cross-building.  If this kernel has modules then build them.
# Leave the kernel, system map and any kernel modules in place; get them
# later.
#
if [[ "${target}" = "uImage" ]]; then
	_extraPath="${TTYLINUX_CONFIG_DIR}/bootloader-uboot:"
else
	_extraPath=""
fi
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${_extraPath}${XBT_BIN_PATH}:${PATH}" make -j ${njobs} ${target} \
	V=1 \
	ARCH=${XBT_LINUX_ARCH} \
	CROSS_COMPILE=${XBT_TARGET}-
if [[ "${K_MODULES}" = "yes" ]]; then
	PATH="${XBT_BIN_PATH}:${PATH}" make -j ${njobs} modules \
		V=1 \
		ARCH=${XBT_LINUX_ARCH} \
		CROSS_COMPILE=${XBT_TARGET}-
fi
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
unset _extraPath

cd ..

trap - EXIT

return 0

}


# *****************************************************************************
# Collect the built kernel into an as-built packge.
# *****************************************************************************

kernel_collect() {

local kver="${TTYLINUX_KERNEL:-${XBT_LINUX_VER##*-}}"
local _vmlinuz=""

echo -n "f.m__0.p." >&${CONSOLE_FD}

# Setup kernel directories.
#
mkdir "kpkgs"
mkdir "kroot"
mkdir "kroot/boot"
mkdir "kroot/etc"
mkdir "kroot/lib"
mkdir "kroot/lib/modules"

# $ make vmlinux
# $ mipsel-linux-strip vmlinux
# $ echo "root=/dev/ram0 ramdisk_size=8192" >kernel.params
# $ mipsel-linux-objcopy --add-section kernparm=kernel.params vmlinux
# $ mipsel-linux-objcopy --add-section initrd=initrd.gz vmlinux

# echo ""
# echo "linux-${kver}"
# ls -l "linux-${kver}"
# echo ""
# echo "linux-${kver}/arch/${XBT_LINUX_ARCH}"
# ls -l "linux-${kver}/arch/${XBT_LINUX_ARCH}"
# echo ""
# echo "linux-${kver}/arch/${XBT_LINUX_ARCH}/boot"
# ls -l "linux-${kver}/arch/${XBT_LINUX_ARCH}/boot"
# echo ""
# echo "linux-${kver}/arch/${XBT_LINUX_ARCH}/boot/compressed"
# ls -l "linux-${kver}/arch/${XBT_LINUX_ARCH}/boot/compressed"

_vmlinuz="arch/${XBT_LINUX_ARCH}/boot/"
case "${TTYLINUX_PLATFORM}-${TTYLINUX_CLASS}" in
	beagle_xm-*)  _vmlinuz+="uImage"  ;;
	malta_lv-*)   _vmlinuz="vmlinuz"  ;;
	pc-*)         _vmlinuz+="bzImage" ;;
	wrtu54g_tm-*) _vmlinuz="vmlinux"  ;;
	*-*)          _vmlinuz+="zImage"  ;;
esac

# Get the kernel and its system map.
#
bDir="kroot/boot"
cp "linux-${kver}/System.map"  "${bDir}/System.map"
cp "linux-${kver}/vmlinux"     "${bDir}/vmlinux"
cp "linux-${kver}/${_vmlinuz}" "${bDir}/$(basename ${_vmlinuz})"
unset bDir

if [[ "${K_MODULES}" = "yes" ]]; then

	bDir="${TTYLINUX_CONFIG_DIR}/kroot"
	pDir="${TTYLINUX_CONFIG_DIR}/kpkgs"

	# Install the kernel modules into ${TTYLINUX_CONFIG_DIR}/kroot
	#
	cd "linux-${kver}"
	source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
	PATH="${XBT_BIN_PATH}:${PATH}" make -j ${njobs} modules_install \
		V=1 \
		ARCH=${XBT_LINUX_ARCH} \
		CROSS_COMPILE=${XBT_TARGET}- \
		INSTALL_MOD_PATH=${bDir}
	source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
	cd ..

	# Scrub the modules directory.
	#
	rm --force "${bDir}/lib/modules/${kver}/build"
	rm --force "${bDir}/lib/modules/${kver}/source"

	# Make the binary package in ${TTYLINUX_CONFIG_DIR}/kpkgs
	#
	uTarBall="${pDir}/kmodules-${kver}-${TTYLINUX_CPU}.tar"
	cTarBall="${pDir}/kmodules-${kver}-${TTYLINUX_CPU}.tbz"
	tar --directory ${bDir} --create --file="${uTarBall}" lib
	bzip2 --force "${uTarBall}"
	mv --force "${uTarBall}.bz2" "${cTarBall}"
	cp "${cTarBall}" "${TTYLINUX_PKGBIN_DIR}"
	unset uTarBall
	unset cTarBall

	unset bDir
	unset pDir

fi

echo -n "c" >&${CONSOLE_FD}
echo "i> Removing build directory linux-${kver}"
rm --force --recursive "linux-${kver}/"
rm --force --recursive "linux/"

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

K_MODULES="no"

source ./ttylinux-config.sh
source ${TTYLINUX_DIR}/scripts/_functions.sh

dist_root_check    || exit 1
dist_config_setup  || exit 1
build_config_setup || exit 1
build_spec_show    || exit 1

if [[ ! -d "${TTYLINUX_CONFIG_DIR}" ]]; then
	echo "E> The config directory does NOT exist." >&2
	echo "E>      ${TTYLINUX_CONFIG_DIR}" >&2
	exit 1
fi


# *****************************************************************************
# Main Program
# *****************************************************************************

echo ""
echo "##### START cross-building the kernel"
echo "g - getting the source and configuration packages"
echo "b - building and installing the package into build-root"
echo "f - finding installed files"
echo "m - looking for man pages to compress"
echo "p - creating installable package"
echo "c - cleaning"
echo ""

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

pname="linux-${TTYLINUX_KERNEL:-${XBT_LINUX_VER##*-}}"

t1=${SECONDS}
echo -n "${TTYLINUX_CPU} ${pname} ";
for ((i=(20-${#pname}) ; i > 0 ; i--)); do echo -n "."; done
echo -n " ";

exec 4>&1    # Save stdout at fd 4.
CONSOLE_FD=4 #

rm --force "${TTYLINUX_VAR_DIR}/log/${pname}.log"
kernel_get     >>"${TTYLINUX_VAR_DIR}/log/${pname}.log" 2>&1
kernel_xbuild  >>"${TTYLINUX_VAR_DIR}/log/${pname}.log" 2>&1
kernel_collect >>"${TTYLINUX_VAR_DIR}/log/${pname}.log" 2>&1

exec >&4     # Set fd 1 back to stdout.
CONSOLE_FD=1 #

echo -n " ... DONE ["
t2=${SECONDS}
mins=$(((${t2}-${t1})/60))
secs=$(((${t2}-${t1})%60))
[[ ${#mins} -eq 1 ]] && echo -n " "; echo -n "${mins} minutes "
[[ ${#secs} -eq 1 ]] && echo -n " "; echo    "${secs} seconds]"

popd >/dev/null 2>&1

echo ""
echo "##### DONE cross-building the kernel"


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
