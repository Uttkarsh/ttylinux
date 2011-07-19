#!/bin/bash


# Inherited Variables:
#
# TTYLINUX_XTOOL_DIR = ${XBT_DIR}/${TTYLINUX_XBT}


# *****************************************************************************
# Constants
# *****************************************************************************

U_BOOT="u-boot-2010.12"


# *****************************************************************************
# Check Command Line Arguments
# *****************************************************************************

if [[ $# -eq 0 ]]; then
	echo "$(basename $0) called with no arguments; one argument is needed."
	exit 1
fi
[[ "$1" != "no" ]] || exit 0
ubootTarget=$1
echo ""
echo "=> Making u-boot (${ubootTarget})"


# *****************************************************************************
# Remove any left-over previous build things.  Then untar U-Boot source package.
# *****************************************************************************

echo "Removing any left-over build products and untarring ${U_BOOT} ..."
rm -rf u-boot.bin mkimage
rm -rf ${U_BOOT}
tar -xf ${U_BOOT}.tar.bz2


# *****************************************************************************
# Build U-Boot
# *****************************************************************************

cd ${U_BOOT}

oldPath=${PATH}
export PATH="${TTYLINUX_XTOOL_DIR}/host/usr/bin:${PATH}"

if [[ x"${ubootTarget}" = x"mkimage" ]]; then
	# Make the host tools.
	rm -f ../${ubootTarget}.MAKELOG
	make tools >../${ubootTarget}.MAKELOG 2>&1
	#
	# Get the mkimage program.
	cp tools/mkimage ..
else
	# Make the "u-boot.bin" and its host tools.
	rm -f ../${ubootTarget}.MAKELOG
	CROSS_COMPILE=${TTYLINUX_XBT}- ./MAKEALL ${ubootTarget} | grep -v "^$"
	cp LOG/${ubootTarget}.MAKELOG ..
	#
	# Get the programs.
	cp u-boot.bin ..
	cp tools/mkimage ..
fi

export PATH=${oldPath}

cd ..

[[ -f u-boot.bin ]] && ls --color -lh u-boot.bin || true
[[ -f mkimage    ]] && ls --color -lh mkimage    || true


# *****************************************************************************
# Cleanup
# *****************************************************************************

rm -rf "${U_BOOT}"

unset CROSS_COMPILE
unset U_BOOT
unset oldPath
unset ubootTarget


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0
