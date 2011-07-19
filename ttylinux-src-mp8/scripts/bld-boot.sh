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
#	This script makes the ttylinux bootable ISO image file.
#
# CHANGE LOG
#
#	09apr11	drj	Added wrtu54g_tm kernel+ramdisk binary.
#	30mar11	drj	Added wrtu54g_tm.  Changed away from ISO for some.
#	09feb11	drj	Removed the package list file "packages.txt".
#	24jan11	drj	Added the binary packages to the ISO image.
#	03jan11	drj	Added TTYLINUX_CLASS to kernel configuration file.
#	02jan11	drj	Added TTYLINUX_CLASS shell scripts added to ISO.
#	21dec10	drj	Changed for the new alternate Linux location.
#	11dec10	drj	Changed for the new config directory structure.
#	11dec10	drj	Changed for the new platform directory structure.
#	16nov10	drj	Reorganization of config/boot to config/kroot.
#	09oct10	drj	Minor simplifications.
#	17jul10	drj	Setup the initrd size kernel parameter for x86.
#	02apr10	drj	Changed for platform re-organization.
#	30mar10	drj	Renamed this file to build-iso.sh
#	28mar10	drj	Added the PowerPC ISO image.
#	26mar10	drj	Added the kernel vmlinux file to the ISO image.
#	23mar10	drj	Added the kernel System.map file to the ISO image.
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
# Build the BeagleBoard ttylinux binary distribution tarball.
# *****************************************************************************

tarball_beagle_make() {

local kver="${XBT_LINUX_VER#*-}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kver="${TTYLINUX_KERNEL}"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
	unset srcd
fi

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Recreating boot staging directory ................. "
rm --force --recursive "sdcard/"
mkdir --mode=755 "sdcard/"
mkdir --mode=755 "sdcard/boot/"
mkdir --mode=755 "sdcard/config/"
mkdir --mode=755 "sdcard/doc/"
mkdir --mode=755 "sdcard/packages/"
echo "DONE"

echo -n "i> Gathering boot files .............................. "
>sdcard/LABEL
echo "SOURCE_TIMESTAMP=\"$(date)\""           >>sdcard/LABEL
echo "SOURCE_MEDIA=\"UNKNOWN\""               >>sdcard/LABEL
echo "SOURCE_VERSION=\"${TTYLINUX_VERSION}\"" >>sdcard/LABEL
echo "SOURCE_ARCH=\"${TTYLINUX_CPU}\""        >>sdcard/LABEL
echo "SOURCE_KVER=\"${kver}\""                >>sdcard/LABEL
cp ${TTYLINUX_DOC_DIR}/AUTHORS     sdcard/AUTHORS
cp ${TTYLINUX_DOC_DIR}/COPYING     sdcard/COPYING
cp bootloader-xload/x-load.bin.ift sdcard/boot/MLO
cp bootloader-uboot/u-boot.bin     sdcard/boot/u-boot.bin
cp ${TTYLINUX_IMG_NAME}            sdcard/boot/filesys
cp kroot/boot/System.map           sdcard/boot/System.map
cp kroot/boot/uImage               sdcard/boot/uImage
cp kroot/boot/vmlinux              sdcard/boot/vmlinux
cp ${TTYLINUX_PLATFORM_DIR}/uboot-boot.cmd sdcard/boot/boot.cmd
cp ${TTYLINUX_PLATFORM_DIR}/uboot-user.cmd sdcard/boot/user.cmd
chmod 644 sdcard/AUTHORS
chmod 644 sdcard/COPYING
echo "DONE"

echo -n "i> Compressing root file system initrd ............... "
gzip sdcard/boot/filesys
bootloader-uboot/mkimage \
	-A arm \
	-O linux \
	-T ramdisk \
	-C gzip \
	-a 0 \
	-e 0 \
	-n "ramdisk" \
	-d sdcard/boot/filesys.gz \
	sdcard/boot/ramdisk.gz >/dev/null 2>&1
rm -rf sdcard/boot/filesys.gz
echo "DONE"

echo -n "i> Set the initrd file system size ................... "
_rdSize=$((${TTYLINUX_FSI_SIZE}*1024))
sed --in-place \
	--expression="s/ramdisk_size=[0-9]*/ramdisk_size=${_rdSize}/" \
	sdcard/boot/boot.cmd
unset _rdSize
echo "DONE"

echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat sdcard/boot/boot.cmd
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

echo -n "i> Converting boot.cmd and user.cmd .................. "
bootloader-uboot/mkimage \
	-A arm \
	-O linux \
	-T script \
	-C none \
	-a 0 \
	-e 0 \
	-n "U-Boot Script"  \
	-d sdcard/boot/boot.cmd \
	sdcard/boot/boot.scr >/dev/null 2>&1
bootloader-uboot/mkimage \
	-A arm \
	-O linux \
	-T script \
	-C none \
	-a 0 \
	-e 0 \
	-n "U-Boot Script" \
	-d sdcard/boot/user.cmd \
	sdcard/boot/user.scr >/dev/null 2>&1
echo "DONE"

echo -n "i> Copying configuration data and tools .............. "
cp ${kcfg} sdcard/config/kernel-${kver}.cfg
for f in ${TTYLINUX_PLATFORM_DIR}/*-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh; do
	[[ -r "${f}" ]] && cp ${f} sdcard/ || true
done
echo "DONE"

echo -n "i> Copying documentation files ....................... "
_chgLog="ChangeLog-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
cp ${TTYLINUX_DOC_DIR}/${_chgLog}      sdcard/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.html sdcard/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.pdf  sdcard/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.tex  sdcard/doc/
unset _chgLog
chmod 644 sdcard/doc/*
echo "DONE"

echo -n "i> Copying packages .................................. "
cp ${TTYLINUX_PKGBIN_DIR}/* sdcard/packages/
echo "DONE"

echo -n "i> Zipping staging directory ......................... "
rm -rf ${TTYLINUX_TAR_NAME}
tar -C sdcard/ -cjf ${TTYLINUX_TAR_NAME} .
echo "DONE"

echo ""
ls --color -hl ${TTYLINUX_TAR_NAME} | sed --expression="s|${TTYLINUX_DIR}/||"
echo "i> distribution file $(basename ${TTYLINUX_TAR_NAME}) is ready."

popd >/dev/null 2>&1

return 0

}


# *****************************************************************************
# Build a general ARM ttylinux binary distribution tarball.
# *****************************************************************************

tarball_arm_make() {

local kver="${XBT_LINUX_VER#*-}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kver="${TTYLINUX_KERNEL}"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
	unset srcd
fi

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Recreating ISO directory .......................... "
rm --force --recursive "cdrom/"
mkdir --mode=755 "cdrom/"
mkdir --mode=755 "cdrom/boot/"
mkdir --mode=755 "cdrom/config/"
mkdir --mode=755 "cdrom/doc/"
mkdir --mode=755 "cdrom/packages/"
echo "DONE"

echo -n "i> Gathering boot files .............................. "
>cdrom/LABEL
echo "SOURCE_TIMESTAMP=\"$(date)\""           >>cdrom/LABEL
echo "SOURCE_MEDIA=\"CDROM\""                 >>cdrom/LABEL
echo "SOURCE_VERSION=\"${TTYLINUX_VERSION}\"" >>cdrom/LABEL
echo "SOURCE_ARCH=\"${TTYLINUX_CPU}\""        >>cdrom/LABEL
echo "SOURCE_KVER=\"${kver}\""                >>cdrom/LABEL
cp ${TTYLINUX_DOC_DIR}/AUTHORS cdrom/AUTHORS
cp ${TTYLINUX_DOC_DIR}/COPYING cdrom/COPYING
cp kroot/boot/System.map       cdrom/boot/System.map
cp kroot/boot/vmlinux          cdrom/boot/vmlinux
cp kroot/boot/zImage           cdrom/boot/vmlinuz
cp ${TTYLINUX_IMG_NAME}        cdrom/boot/initrd
echo "DONE"

echo -n "i> Compress the file system .......................... "
gzip --no-name cdrom/boot/initrd
mv cdrom/boot/initrd.gz cdrom/boot/initrd
echo "DONE"

echo -n "i> Copying configuration data and tools to Boot CD ... "
cp ${kcfg} cdrom/config/kernel-${kver}.cfg
for f in ${TTYLINUX_PLATFORM_DIR}/*-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh; do
	[[ -r "${f}" ]] && cp ${f} cdrom/ || true
done
echo "DONE"

echo -n "i> Copying documentation files to Boot CD ............ "
_chgLog="ChangeLog-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
cp ${TTYLINUX_DOC_DIR}/${_chgLog}      cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.html cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.pdf  cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.tex  cdrom/doc/
unset _chgLog
echo "DONE"

echo -n "i> Copying packages to Boot CD ....................... "
cp ${TTYLINUX_PKGBIN_DIR}/* cdrom/packages/
echo "DONE"

echo ""
echo "i> Creating CD-ROM ISO image ..."
find cdrom -type d -exec chmod 755 {} \;
find cdrom -type f -exec chmod 755 {} \;
mkisofs	-joliet							\
	-rational-rock						\
	-output ${TTYLINUX_ISO_NAME}				\
	-volid "ttylinux ${TTYLINUX_VERSION} ${TTYLINUX_CPU}"	\
	cdrom
echo "... DONE"

echo ""
ls --color -hl ${TTYLINUX_ISO_NAME} | sed --expression="s|${TTYLINUX_DIR}/||"
echo "i> ISO image file $(basename ${TTYLINUX_ISO_NAME}) is ready."

popd >/dev/null 2>&1

return 0

}


# *****************************************************************************
# Build a general MIPS ttylinux binary distribution tarball.
# *****************************************************************************

tarball_mips_make() {

local kver="${XBT_LINUX_VER#*-}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kver="${TTYLINUX_KERNEL}"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
	unset srcd
fi

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Recreating ISO directory .......................... "
rm --force --recursive "cdrom/"
mkdir --mode=755 "cdrom/"
mkdir --mode=755 "cdrom/boot/"
mkdir --mode=755 "cdrom/config/"
mkdir --mode=755 "cdrom/doc/"
mkdir --mode=755 "cdrom/packages/"
echo "DONE"

echo -n "i> Gathering boot files .............................. "
>cdrom/LABEL
echo "SOURCE_TIMESTAMP=\"$(date)\""           >>cdrom/LABEL
echo "SOURCE_MEDIA=\"CDROM\""                 >>cdrom/LABEL
echo "SOURCE_VERSION=\"${TTYLINUX_VERSION}\"" >>cdrom/LABEL
echo "SOURCE_ARCH=\"${TTYLINUX_CPU}\""        >>cdrom/LABEL
echo "SOURCE_KVER=\"${kver}\""                >>cdrom/LABEL
cp ${TTYLINUX_DOC_DIR}/AUTHORS cdrom/AUTHORS
cp ${TTYLINUX_DOC_DIR}/COPYING cdrom/COPYING
cp kroot/boot/System.map       cdrom/boot/System.map
cp kroot/boot/vmlinux          cdrom/boot/vmlinux
cp kroot/boot/vmlinuz          cdrom/boot/vmlinuz
cp ${TTYLINUX_IMG_NAME}        cdrom/boot/initrd
echo "DONE"

echo -n "i> Compress the file system .......................... "
gzip --no-name cdrom/boot/initrd
mv cdrom/boot/initrd.gz cdrom/boot/initrd
echo "DONE"

echo -n "i> Copying configuration data and tools to Boot CD ... "
cp ${kcfg} cdrom/config/kernel-${kver}.cfg
for f in ${TTYLINUX_PLATFORM_DIR}/*-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh; do
	[[ -r "${f}" ]] && cp ${f} cdrom/ || true
done
echo "DONE"

echo -n "i> Copying documentation files to Boot CD ............ "
_chgLog="ChangeLog-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
cp ${TTYLINUX_DOC_DIR}/${_chgLog}      cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.html cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.pdf  cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.tex  cdrom/doc/
unset _chgLog
echo "DONE"

echo -n "i> Copying packages to Boot CD ....................... "
cp ${TTYLINUX_PKGBIN_DIR}/* cdrom/packages/
echo "DONE"

echo ""
echo "i> Creating CD-ROM ISO image ..."
find cdrom -type d -exec chmod 755 {} \;
find cdrom -type f -exec chmod 755 {} \;
mkisofs	-joliet							\
	-rational-rock						\
	-output ${TTYLINUX_ISO_NAME}				\
	-volid "ttylinux ${TTYLINUX_VERSION} ${TTYLINUX_CPU}"	\
	cdrom
echo "... DONE"

echo ""
ls --color -hl ${TTYLINUX_ISO_NAME} | sed --expression="s|${TTYLINUX_DIR}/||"
echo "i> ISO image file $(basename ${TTYLINUX_ISO_NAME}) is ready."

popd >/dev/null 2>&1

return 0

}


# *****************************************************************************
# Build the WRTU54G-TM ttylinux binary distribution tarball.
# *****************************************************************************

# The string used with the mkimage -n option for the kernel image name must be
# "ADM8668 Linux Kernel(2.4.31)" for the vendor bootloader, otherwise the the
# vendor bootloader won't run the kernel.

wrtu54g_bin_make() {

# This function shamelessly nicked from Scott Nicholas <neutronscott@scottn.us>
# Copyright (C) 2011 Scott Nicholas <neutronscott@scottn.us>
#
# The binary kernel is padded to 64k boundary and the ramdisk is appened.
# u-boot mkimage puts a 64 byte header on the kernel and a 12 byte header on
# the ramdisk, so the kernel size is addjusted so the ramdisk binary begins
# on a 64KB boundary.

local sysmap="kroot/boot/System.map"
local kernel="sdcard/boot/vmlinux.bin"
local ramdisk="sdcard/boot/filesys.gz"
local kernelLoad_H=""
local kernelLoad_D=0
local kernelEntry_H=""
local kernelEntry_D=0
local origKernelSize=0
local kernelSize=0

kernelLoad_H=$(grep "A _text" ${sysmap} | cut -d ' ' -f 1)
kernelLoad_H=${kernelLoad_H#ffffffff}
kernelLoad_D=$((0x${kernelLoad_H#ffffffff})) # Convert hex to decimal

KernelEntry_H=$(grep "T kernel_entry" ${sysmap} | cut -d ' ' -f 1)
KernelEntry_H=${KernelEntry_H#ffffffff}
kernelEntry_D=$((0x${KernelEntry_H#ffffffff})) # Convert hex to decimal

origKernelSize=$(stat -c%s ${kernel})
kernelSize=$(((${origKernelSize} / 65536 + 1) * 65536 - 64 - 12))
if [[ ${kernelSize} -lt ${origKernelSize} ]]; then
	kernelSize=$((${kernelSize} + 65536))
fi

printf "kernel_load  = 0x%08x\n" ${kernelLoad_D}
printf "kernel_entry = 0x%08x\n" ${kernelEntry_D}
printf "kernel_size  = 0x%08x\n" ${kernelSize}
printf "ramdisk_offs = 0x%08x\n" $((${kernelSize} + 64 + 12 ))
printf "ramdisk_load = kernel_load + ramdisk_offset = 0x%08x\n" \
	$((${kernelLoad_D} + ${kernelSize} + 64 + 12 ))

dd if=${kernel}  of=aligned.kernel  bs=${kernelSize} conv=sync >/dev/null 2>&1
dd if=${ramdisk} of=aligned.ramdisk bs=64k           conv=sync >/dev/null 2>&1

bootloader-uboot/mkimage \
	-A mips \
	-O linux \
	-T multi \
	-C none \
	-a 0x${kernelLoad_H} \
	-e 0x${KernelEntry_H} \
	-n "ADM8668 Linux Kernel(2.4.31)" \
	-d aligned.kernel:aligned.ramdisk \
	sdcard/boot/vmlinux-ramdisk.bin

rm aligned.kernel
rm aligned.ramdisk

}

# **************************************

tarball_wrtu54g_make() {

local kver="${XBT_LINUX_VER#*-}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kver="${TTYLINUX_KERNEL}"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
	unset srcd
fi

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Recreating boot staging directory ................. "
rm --force --recursive "sdcard/"
mkdir --mode=755 "sdcard/"
mkdir --mode=755 "sdcard/boot/"
mkdir --mode=755 "sdcard/config/"
mkdir --mode=755 "sdcard/doc/"
mkdir --mode=755 "sdcard/packages/"
echo "DONE"

echo -n "i> Gathering boot files .............................. "
>sdcard/LABEL
echo "SOURCE_TIMESTAMP=\"$(date)\""           >>sdcard/LABEL
echo "SOURCE_MEDIA=\"UNKNOWN\""               >>sdcard/LABEL
echo "SOURCE_VERSION=\"${TTYLINUX_VERSION}\"" >>sdcard/LABEL
echo "SOURCE_ARCH=\"${TTYLINUX_CPU}\""        >>sdcard/LABEL
echo "SOURCE_KVER=\"${kver}\""                >>sdcard/LABEL
cp ${TTYLINUX_DOC_DIR}/AUTHORS sdcard/AUTHORS
cp ${TTYLINUX_DOC_DIR}/COPYING sdcard/COPYING
cp ${TTYLINUX_IMG_NAME}        sdcard/boot/filesys
cp kroot/boot/System.map       sdcard/boot/System.map
cp kroot/boot/vmlinux          sdcard/boot/vmlinux
chmod 644 sdcard/AUTHORS
chmod 644 sdcard/COPYING
echo "DONE"

echo -n "i> Creating binary vmlinux.bin from elf vmlinux ...... "
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" ${XBT_TARGET}-objcopy \
	-O binary -S sdcard/boot/vmlinux sdcard/boot/vmlinux.bin
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
echo "DONE"

echo -n "i> Compressing root file system initrd: filesys.gz ... "
gzip sdcard/boot/filesys
echo "DONE"

echo "   -------------------------------------------------------"
echo "i> Making flash load binary kernel+ramdisk"
wrtu54g_bin_make sdcard/boot/vmlinux-ramdisk.bin
echo "   -------------------------------------------------------"

echo -n "i> Making uImage with vimlinux.bin.gz for u-boot ..... "
gzip sdcard/boot/vmlinux.bin
bootloader-uboot/mkimage \
	-A mips \
	-O linux \
	-T kernel \
	-C gzip \
	-a 0x80002000 \
	-e 0x80006220  \
	-n "ADM8668 Linux Kernel(2.4.31)" \
	-d sdcard/boot/vmlinux.bin.gz \
	sdcard/boot/uImage >/dev/null 2>&1
gunzip sdcard/boot/vmlinux.bin.gz
echo "DONE"

echo -n "i> Making ramdisk.gz with filesys.gz for u-boot ...... "
bootloader-uboot/mkimage \
	-A mips \
	-O linux \
	-T ramdisk \
	-C gzip \
	-a 0 \
	-e 0 \
	-n "ramdisk" \
	-d sdcard/boot/filesys.gz \
	sdcard/boot/ramdisk.gz >/dev/null 2>&1
echo "DONE"

echo -n "i> Removing compressed root file system filesys.gz ... "
rm -rf sdcard/boot/filesys.gz
echo "DONE"

echo -n "i> Copying configuration data and tools .............. "
cp ${kcfg} sdcard/config/kernel-${kver}.cfg
for f in ${TTYLINUX_PLATFORM_DIR}/*-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh; do
	[[ -r "${f}" ]] && cp ${f} sdcard/ || true
done
echo "DONE"

echo -n "i> Copying documentation files ....................... "
_chgLog="ChangeLog-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
cp ${TTYLINUX_DOC_DIR}/${_chgLog}      sdcard/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.html sdcard/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.pdf  sdcard/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.tex  sdcard/doc/
unset _chgLog
chmod 644 sdcard/doc/*
echo "DONE"

echo -n "i> Copying packages .................................. "
cp ${TTYLINUX_PKGBIN_DIR}/* sdcard/packages/
echo "DONE"

echo -n "i> Zipping staging directory ......................... "
rm -rf ${TTYLINUX_TAR_NAME}
tar -C sdcard/ -cjf ${TTYLINUX_TAR_NAME} .
echo "DONE"

echo ""
ls --color -hl ${TTYLINUX_TAR_NAME} | sed --expression="s|${TTYLINUX_DIR}/||"
echo "i> distribution file $(basename ${TTYLINUX_TAR_NAME}) is ready."

popd >/dev/null 2>&1

return 0

}


# *****************************************************************************
# Build the Power Macintosh boot CD with the kernel and file system.
# *****************************************************************************

bootiso_pmac_make() {

local kver="${XBT_LINUX_VER#*-}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"
local rdSize

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kver="${TTYLINUX_KERNEL}"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
	unset srcd
fi

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Recreating ISO directory .......................... "
rm --force --recursive "cdrom/"
mkdir --mode=755 "cdrom/"
mkdir --mode=755 "cdrom/boot/"
mkdir --mode=755 "cdrom/config/"
mkdir --mode=755 "cdrom/doc/"
mkdir --mode=755 "cdrom/packages/"
mkdir --mode=755 "cdrom/ppc/"
mkdir --mode=755 "cdrom/ppc/chrp/"
echo "DONE"

echo -n "i> Gathering boot files .............................. "
>cdrom/LABEL
echo "SOURCE_TIMESTAMP=\"$(date)\""           >>cdrom/LABEL
echo "SOURCE_MEDIA=\"CDROM\""                 >>cdrom/LABEL
echo "SOURCE_VERSION=\"${TTYLINUX_VERSION}\"" >>cdrom/LABEL
echo "SOURCE_ARCH=\"${TTYLINUX_CPU}\""        >>cdrom/LABEL
echo "SOURCE_KVER=\"${kver}\""                >>cdrom/LABEL
cp ${TTYLINUX_DOC_DIR}/AUTHORS    cdrom/AUTHORS
cp ${TTYLINUX_DOC_DIR}/COPYING    cdrom/COPYING
cp bootloader-yaboot/boot.msg     cdrom/boot/boot.msg
cp bootloader-yaboot/hfsmap       cdrom/boot/hfsmap
cp bootloader-yaboot/ofboot.b     cdrom/boot/ofboot.b
cp bootloader-yaboot/yaboot       cdrom/boot/yaboot
cp bootloader-yaboot/yaboot.conf  cdrom/boot/yaboot.conf
cp bootloader-yaboot/yaboot.conf  cdrom/yaboot.conf
cp bootloader-yaboot/bootinfo.txt cdrom/ppc/bootinfo.txt
cp ${TTYLINUX_IMG_NAME}           cdrom/boot/filesys
cp kroot/boot/System.map          cdrom/boot/System.map
cp kroot/boot/vmlinux             cdrom/boot/vmlinux
cp kroot/boot/zImage              cdrom/boot/vmlinuz
echo "DONE"

echo -n "i> Compress the file system .......................... "
gzip --no-name cdrom/boot/filesys
echo "DONE"

echo -n "i> Set the initrd file system size ................... "
rdSize=$((${TTYLINUX_FSI_SIZE}*1024))
sed --in-place \
	--expression="s/ramdisk_size=[0-9]*/ramdisk_size=${rdSize}/" \
	cdrom/boot/yaboot.conf
sed --in-place \
	--expression="s/ramdisk_size=[0-9]*/ramdisk_size=${rdSize}/" \
	cdrom/yaboot.conf
echo "DONE"

echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat cdrom/boot/yaboot.conf
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

echo -n "i> Copying configuration data and tools to Boot CD ... "
rdSize=$((${TTYLINUX_FSI_SIZE}*1024))
sed --in-place \
	--expression="s/ramdisk_size=[0-9]*/ramdisk_size=${rdSize}/" \
	${TTYLINUX_PLATFORM_DIR}/qemu-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh
cp ${kcfg} cdrom/config/kernel-${kver}.cfg
for f in ${TTYLINUX_PLATFORM_DIR}/*-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh; do
	[[ -r "${f}" ]] && cp ${f} cdrom/ || true
done
echo "DONE"

echo -n "i> Copying documentation files to Boot CD ............ "
_chgLog="ChangeLog-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
cp ${TTYLINUX_DOC_DIR}/${_chgLog}      cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.html cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.pdf  cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.tex  cdrom/doc/
unset _chgLog
echo "DONE"

echo -n "i> Copying packages to Boot CD ....................... "
cp ${TTYLINUX_PKGBIN_DIR}/* cdrom/packages/
echo "DONE"

echo ""
echo "i> Creating CD-ROM ISO image ..."
find cdrom -type d -exec chmod 755 {} \;
find cdrom -type f -exec chmod 755 {} \;
mkisofs							\
	-v						\
	-J						\
	-l						\
	-r						\
	-hide-rr-moved					\
	-pad						\
	-o ${TTYLINUX_ISO_NAME}				\
	-V "ttylinux ${TTYLINUX_VERSION} ppc"		\
	-hfs -part					\
	-map "$(pwd)/cdrom/boot/hfsmap"			\
	-hfs-volid "ttylinux ${TTYLINUX_VERSION} ppc"	\
	-no-desktop					\
	-chrp-boot					\
	-prep-boot boot/yaboot				\
	-hfs-bless cdrom/boot				\
	cdrom
# -----------------------------------------------------------------------------
# Ben DeCamp's (ben@powerpup.yi.org):
#mkisofs -output $2                    \
#    -hfs-volid ttylinux ${SOURCE_VERSION} powerpc    \
#    -hfs -part -r -l -r -J -v            \
#    -map /boot/hfsmap            \
#    -no-desktop                    \
#    -chrp-boot                    \
#    -prep-boot boot/yaboot                \
#    -hfs-bless /boot            \
#    $1
# -----------------------------------------------------------------------------
#mkisofs				\
#	-hide-rr-moved			\
#	-hfs				\
#	-part				\
#	-map ./ttylinux/boot/hfsmap	\
#	-no-desktop			\
#	-hfs-volid ttylinux		\
#	-hfs-bless ./ttylinux/boot	\
#	-pad				\
#	-l				\
#	-r				\
#	-J				\
#	-v				\
#	-V ttylinux			\
#	-o ttylinux.iso			\
#	./ttylinux
# -----------------------------------------------------------------------------
# mkisofs \
#	-o boot.iso -chrp-boot -U \
#	-prep-boot ppc/chrp/yaboot \
#	-part -hfs -T -r -l -J \
#	-A "Fedora 4" -sysid PPC -V "PBOOT" -volset 4 -volset-size 1 \
#	-volset-seqno 1 -hfs-volid 4 -hfs-bless $(pwd)/ppc/ppc \
#	-map mapping -magic magic -no-desktop -allow-multidot \
#	$(pwd)/ppc
# -----------------------------------------------------------------------------
# echo "ofboot.b X 'chrp' 'tbxi'" > mapping
# volume_id="PBOOT"
# system_id="PPC"
# volume_set_id="6";
# application_id="Fedora Core 6"
# hfs_volume_id=$volume_set_id
# mkisofs \
#	-volid "$volume_id" -sysid "$system_id" -appid "$application_id" \
#	-volset "$volume_set_id" -untranslated-filenames -joliet \
#	-rational-rock -translation-table -hfs -part \
#	-hfs-volid "$hfs_volume_id" -no-desktop -hfs-creator '????' \
#	-hfs-type '????' -map "$(pwd)/mapping" -chrp-boot \
#	-prep-boot ppc/chrp/yaboot -hfs-bless "$(pwd)/boot-new/ppc/mac" \
#	-o boot-new.iso $(pwd)/boot-new
# -----------------------------------------------------------------------------
echo "... DONE"

echo ""
ls --color -hl ${TTYLINUX_ISO_NAME} | sed --expression="s|${TTYLINUX_DIR}/||"
echo "i> ISO image file $(basename ${TTYLINUX_ISO_NAME}) is ready."

popd >/dev/null 2>&1

return 0

}


# *****************************************************************************
# Build the x86 boot CD with the kernel and file system.
# *****************************************************************************

bootiso_x86_make() {

local kver="${XBT_LINUX_VER#*-}"
local kname="kernel-${kver}-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
local kcfg="${TTYLINUX_PLATFORM_DIR}/${kname}.cfg"
local rdSize

# If TTYLINUX_KERNEL is set, as specified in the ttylinux-config.sh file,
# then there is a non-standard (user custom) ttylinux kernel to build, in which
# case the linux source distribution and kernel configuration file is supposed
# to be in the ttylinux site/platform-* directory.
#
if [[ -n "${TTYLINUX_KERNEL}" ]]; then
	srcd="${TTYLINUX_DIR}/site/$(basename ${TTYLINUX_PLATFORM_DIR})"
	kver="${TTYLINUX_KERNEL}"
	kcfg="${srcd}/kernel-${TTYLINUX_KERNEL}.cfg"
	unset srcd
fi

pushd "${TTYLINUX_CONFIG_DIR}" >/dev/null 2>&1

echo -n "i> Recreating ISO directory .......................... "
rm --force --recursive "cdrom/"
mkdir --mode=755 "cdrom/"
mkdir --mode=755 "cdrom/boot/"
mkdir --mode=755 "cdrom/boot/isolinux/"
mkdir --mode=755 "cdrom/config/"
mkdir --mode=755 "cdrom/doc/"
mkdir --mode=755 "cdrom/packages/"
echo "DONE"

echo -n "i> Gathering boot files .............................. "
>cdrom/LABEL
echo "SOURCE_TIMESTAMP=\"$(date)\""           >>cdrom/LABEL
echo "SOURCE_MEDIA=\"CDROM\""                 >>cdrom/LABEL
echo "SOURCE_VERSION=\"${TTYLINUX_VERSION}\"" >>cdrom/LABEL
echo "SOURCE_ARCH=\"${TTYLINUX_CPU}\""        >>cdrom/LABEL
echo "SOURCE_KVER=\"${kver}\""                >>cdrom/LABEL
cp ${TTYLINUX_DOC_DIR}/AUTHORS      cdrom/AUTHORS
cp ${TTYLINUX_DOC_DIR}/COPYING      cdrom/COPYING
cp bootloader-isolinux/isolinux.bin cdrom/boot/isolinux/isolinux.bin
cp bootloader-isolinux/isolinux.cfg cdrom/boot/isolinux/isolinux.cfg
cp bootloader-isolinux/boot.msg     cdrom/boot/isolinux/boot.msg
cp bootloader-isolinux/help_f2.msg  cdrom/boot/isolinux/help_f2.msg
cp bootloader-isolinux/help_f3.msg  cdrom/boot/isolinux/help_f3.msg
cp bootloader-isolinux/help_f4.msg  cdrom/boot/isolinux/help_f4.msg
cp ${TTYLINUX_IMG_NAME}             cdrom/boot/filesys
cp kroot/boot/System.map            cdrom/boot/System.map
cp kroot/boot/vmlinux               cdrom/boot/vmlinux
cp kroot/boot/bzImage               cdrom/boot/vmlinuz
echo "DONE"

echo -n "i> Compress the root file system initrd .............. "
gzip --no-name cdrom/boot/filesys
echo "DONE"

echo -n "i> Set the initrd file system size ................... "
rdSize=$((${TTYLINUX_FSI_SIZE}*1024))
sed --in-place \
	--expression="s/root=/ramdisk_size=${rdSize} root=/" \
	cdrom/boot/isolinux/isolinux.cfg
echo "DONE"

echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat cdrom/boot/isolinux/isolinux.cfg
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

echo -n "i> Copying configuration data and tools to Boot CD ... "
cp ${kcfg}                      cdrom/config/kernel-${kver}.cfg
cp bootloader-isolinux/syslinux cdrom/config/
cp ttylinux-setup               cdrom/config/
for f in ${TTYLINUX_PLATFORM_DIR}/*-${TTYLINUX_CLASS}-${TTYLINUX_CPU}.sh; do
	[[ -r "${f}" ]] && cp ${f} cdrom/ || true
done
echo "DONE"

echo -n "i> Copying documentation files to Boot CD ............ "
_chgLog="ChangeLog-${TTYLINUX_CLASS}-${TTYLINUX_CPU}"
cp ${TTYLINUX_DOC_DIR}/${_chgLog}           cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/Flash_Disk_Howto.txt cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.html      cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.pdf       cdrom/doc/
cp ${TTYLINUX_DOC_DIR}/User_Guide.tex       cdrom/doc/
unset _chgLog
echo "DONE"

echo -n "i> Copying packages to Boot CD ....................... "
cp ${TTYLINUX_PKGBIN_DIR}/* cdrom/packages/
echo "DONE"

echo ""
echo "i> Creating CD-ROM ISO image ..."
find cdrom -type d -exec chmod 755 {} \;
find cdrom -type f -exec chmod 755 {} \;
mkisofs	-joliet							\
	-rational-rock						\
	-output ${TTYLINUX_ISO_NAME}				\
	-volid "ttylinux ${TTYLINUX_VERSION} ${TTYLINUX_CPU}"	\
	-eltorito-boot boot/isolinux/isolinux.bin		\
	-eltorito-catalog boot/isolinux/boot.cat		\
	-boot-info-table					\
	-boot-load-size 4					\
	-no-emul-boot						\
	cdrom
echo "... DONE"

echo ""
ls --color -hl ${TTYLINUX_ISO_NAME} | sed --expression="s|${TTYLINUX_DIR}/||"
echo "i> ISO image file $(basename ${TTYLINUX_ISO_NAME}) is ready."

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

dist_root_check    || exit 1
dist_config_setup  || exit 1
build_config_setup || exit 1


# *****************************************************************************
# Main Program
# *****************************************************************************

echo "##### START cross-building the boot CD"
echo ""

[[ "${TTYLINUX_PLATFORM}" = "beagle_xm"     ]] && tarball_beagle_make  || true
[[ "${TTYLINUX_PLATFORM}" = "integrator_cp" ]] && tarball_arm_make     || true
[[ "${TTYLINUX_PLATFORM}" = "malta_lv"      ]] && tarball_mips_make    || true
[[ "${TTYLINUX_PLATFORM}" = "wrtu54g_tm"    ]] && tarball_wrtu54g_make || true
[[ "${TTYLINUX_PLATFORM}" = "macintosh_g4"  ]] && bootiso_pmac_make    || true
[[ "${TTYLINUX_PLATFORM}" = "pc"            ]] && bootiso_x86_make     || true

echo ""
echo "##### DONE cross-building the boot CD"


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
