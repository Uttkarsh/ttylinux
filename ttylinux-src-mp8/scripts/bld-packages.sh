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
#	This script builds the ttylinux packages.
#
# CHANGE LOG
#
#	23jan11	drj	Minor fussing.
#	16jan11	drj	Added possible TTYLINUX_CPU-specific file list.
#	14jan11	drj	Changed the exe and lib stripping process.
#	13jan11	drj	Added check and show for left-over stuff in BUILD.
#	10jan11	drj	Changed for merging pkg-bld into pkg-cfg.
#	09jan11	drj	Changed pkg_clean to be called after package collection.
#	03jan11	drj	Fixed file stripping.
#	16nov10	drj	Miscellaneous fussing.
#	09oct10	drj	Minor simplifications.
#	02apr10	drj	Unhandle glibc-* and added _files filter.
#	04mar10	drj	Removed ttylinux.site-config.sh and handle glibc-*.
#	23jul09	drj	Switched to bash, simplified output and fixed $NJOBS.
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Get and untar a source package.
# *****************************************************************************

package_get() {

# Function Arguments:
#      $1 ... Package name, like "glibc-2.12.1".

local srcPkg="$1"
local tarBall=""
local unZipper=""

if [[ -f "${TTYLINUX_PKGSRC_DIR}/${srcPkg}.tgz" ]]; then
	tarBall="${srcPkg}.tgz"
	unZipper="gunzip --force"
fi

if [[ -f "${TTYLINUX_PKGSRC_DIR}/${srcPkg}.tar.gz" ]]; then
	tarBall="${srcPkg}.tar.gz"
	unZipper="gunzip --force"
fi

if [[ -f "${TTYLINUX_PKGSRC_DIR}/${srcPkg}.tbz" ]]; then
	tarBall="${srcPkg}.tbz"
	unZipper="bunzip2 --force"
fi

if [[ -f "${TTYLINUX_PKGSRC_DIR}/${srcPkg}.tar.bz2" ]]; then
	tarBall="${srcPkg}.tar.bz2"
	unZipper="bunzip2 --force"
fi

if [[ -n "${tarBall}" ]]; then
	cp "${TTYLINUX_PKGSRC_DIR}/${tarBall}" .
	${unZipper} "${tarBall}" >/dev/null
	tar --extract --file="${srcPkg}.tar"
	rm --force "${srcPkg}.tar"
fi

}


# *****************************************************************************
# Make a file to list the ttylinux package contents.
# *****************************************************************************

package_list_make() {

# The file cfg-$1/files is an ASCII file that is the list of files from which
# to make the binary package.  cfg-$1/files can have some scripting that
# interprets build script variables to enable the selection of package files
# based upon the shell variables' values, so cfg-$1/files takes some special
# processing.  It is filtered, honoring any ebedded shell scripting, and the
# actual list of binary package files is created as ${TTYLINUX_VAR_DIR}/files

local cfgPkgFiles="$1"

local lineNum=0
local nLineUse=1
local oLineUse=1
local nesting=0

rm --force "${TTYLINUX_VAR_DIR}/files"
>"${TTYLINUX_VAR_DIR}/files"
while read; do
	lineNum=$((${lineNum}+1))
	grep -q "^#if" <<<${REPLY} && {
		if [[ ${nesting} = 1 ]]; then
			echo "E> Cannot nest scripting in cfg-$1/files" >&2
			echo "=> line ${lineNum}: \"${REPLY}\"" >&2
			continue
		fi
		set ${REPLY}
		if [[ $# != 4 ]]; then
			echo "E> IGNORING malformed script in cfg-$1/files" >&2
			echo "=> line ${lineNum}: \"${REPLY}\"" >&2
			continue
		fi
		oLineUse=${nLineUse}
		eval [[ "\$$2" $3 "$4" ]] && nLineUse=1 || nLineUse=0
		nesting=1
	}
	grep -q "^#endif" <<<${REPLY} && { # Manage the #endif lines.  These
		nLineUse=${oLineUse}       # must start in the first column.
		nesting=0
	}
	grep -q "^ *#" <<<${REPLY} && echo "Skipping ${REPLY}"
	grep -q "^ *#" <<<${REPLY} && continue # Manage the comment lines.
	[[ ${nLineUse} = 1 ]] && echo ${REPLY} >>"${TTYLINUX_VAR_DIR}/files"
done <"${cfgPkgFiles}"

}


# *****************************************************************************
# Build a package from source and make a binary package.
# *****************************************************************************

package_xbuild() {

# Function Arguments:
#      $1 ... Package name, like "glibc-2.12.1".

# Check for the package build script.
#
if [[ ! -f "${TTYLINUX_PKGCFG_DIR}/$1/bld.sh" ]]; then
	echo "E> Cannot find build script."
	echo "=> ${TTYLINUX_PKGCFG_DIR}/$1/bld.sh"
	return 1
fi

echo -n "g." >&${CONSOLE_FD}

# Get the source package, if any.
#
package_get $1

# Get the ttylinux-specific rootfs, if any.
#
if [[ -f "${TTYLINUX_PKGCFG_DIR}/$1/rootfs.tar.bz2" ]]; then
	cp "${TTYLINUX_PKGCFG_DIR}/$1/rootfs.tar.bz2" .
	bunzip2 --force "rootfs.tar.bz2"
	tar --extract --file="rootfs.tar"
	rm --force "rootfs.tar"
fi

# Prepare to create a list of the installed files.
#
rm --force INSTALL_STAMP
rm --force FILES
>INSTALL_STAMP
>FILES
sleep 1 # For detecting files newer than INSTALL_STAMP

# ${TTYLINUX_PKGCFG_DIR}/$1/bld.sh defines several variables and functions:
#
# Functions
#
#	pkg_patch	This function applies any patches or fixups to the
#			source package before building.
#			NOTE -- Patches are applied before package
#				configuration.
#
#	pkg_configure	This function configures the source package for
#			building.
#			NOTE -- Post-configuration patches might be applied.
#
#	pkg_make	This function builds the source package in place in the
#			${TTYLINUX_BUILD_DIR}/BUILD/ directory
#
#	pkg_install	This function installs any built items into the build
#			root ${TTYLINUX_BUILD_DIR}/ directory tree.
#
#	pkg_clean	This function is responsible for cleaning-up,
#			particularly in error conditions.
#			NOTE -- pkg_clean is not called until package
#				collection in the package_collect() function
#				below.
#
# Variables
#
#	PKG_NAME	For example, "glibc".
#
#	PKG_VERSION	For example, "2.12.1".
#
#	PKG_BLD_PARTS	This is set to the names of any other source packages
#			that are needed to build the packages; these source
#			packages, if specified, must be in TTYLINUX_PKGSRC_DIR.
#
#	PKG_STATUS	Set by the above function to indicate an error worthy
#			stopping the build process.
#
source "${TTYLINUX_PKGCFG_DIR}/$1/bld.sh"

if [[ "$1" != "${PKG_NAME}-${PKG_VERSION}" ]]; then
	echo 'Blammo!' >&${CONSOLE_FD}
	return 1
fi

# Get any other needed source packages.
#
for pkg in ${PKG_BLD_PARTS}; do
	[[ -n "${pkg}" ]] && package_get ${pkg} || true
done; unset pkg

# Patch, configure, build and install.  Note: pkg_clean is not called until
# package collection, in the package_collect() function below, unless pkg_build
# reports an error in PKG_STATUS.
#
PKG_STATUS=""
NJOBS=${ncpus:-1} # Setup ${NJOBS} for parallel makes
bitch=$(sed --expression="s/[[0-9]]//g" <<<"${NJOBS}")
[[ -n "${bitch}" ]] && NJOBS=$((${bitch} + 1)) || NJOBS=1
unset bitch
echo -n "b." >&${CONSOLE_FD}
pkg_patch     $1
pkg_configure $1
pkg_make      $1
pkg_install   $1
unset NJOBS
if [[ -n "${PKG_STATUS}" ]]; then
	pkg_clean # Call function pkg_clean from "bld.sh".
	rm --force INSTALL_STAMP
	rm --force FILES
	echo "E> Package error: ${PKG_STATUS}" >&2
	return 1
fi
if [[ -x "${TTYLINUX_SITE_DIR}/pkg_build.sh" ]]; then
	("${TTYLINUX_SITE_DIR}/pkg_build.sh" $1)
fi
unset PKG_STATUS

# Remove the un-tarred source package directory, the un-tarred rootfs directory
# and any other needed un-tarred source package directories.
#
[[ -d "$1"     ]] && rm --force --recursive "$1"     || true
[[ -d "rootfs" ]] && rm --force --recursive "rootfs" || true
for pkg in ${PKG_BLD_PARTS}; do
	[[ -d "${pkg}" ]] && rm --force --recursive ${pkg} || true
done; unset pkg

# Make a list of the installed files.  Remove build-root and its path component
# from the file names.
#
echo -n "f." >&${CONSOLE_FD}
find ${TTYLINUX_BUILD_DIR} -newer INSTALL_STAMP | sort >> FILES
sed --in-place "FILES" --expression="\#^${TTYLINUX_BUILD_DIR}\$#d"
sed --in-place "FILES" --expression="\#^${TTYLINUX_BUILD_DIR}/BUILD#d"
sed --in-place "FILES" --expression="s|^${TTYLINUX_BUILD_DIR}/||"
rm --force INSTALL_STAMP # All done with the INSTALL_STAMP file.

# Strip when possible.
#
XBT_STRIP="${TTYLINUX_XTOOL_DIR}/host/usr/bin/${TTYLINUX_XBT}-strip"
_bname=""
if [[ x"${TTYLINUX_STRIP_BINS}" = x"yes" ]]; then
	echo "***** stripping"
	for f in $(<FILES); do
		[[ -d "${TTYLINUX_BUILD_DIR}/${f}" ]] && continue || true
		if [[ "$(dirname ${f})" = "bin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_BUILD_DIR}/${f}" || true
		fi
		if [[ "$(dirname ${f})" = "sbin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_BUILD_DIR}/${f}" || true
		fi
		if [[ "$(dirname ${f})" = "usr/bin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_BUILD_DIR}/${f}" || true
		fi
		if [[ "$(dirname ${f})" = "usr/sbin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_BUILD_DIR}/${f}" || true
		fi
_bname="$(basename ${f})"
[[ $(expr "${_bname}" : ".*\\(.o\)$" ) = ".o" ]] && continue || true
[[ $(expr "${_bname}" : ".*\\(.a\)$" ) = ".a" ]] && continue || true
		if [[ "$(dirname ${f})" = "lib" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_BUILD_DIR}/${f}" || true
		fi
[[ "${_bname}" = "libgcc_s.so"   ]] && continue || true
[[ "${_bname}" = "libgcc_s.so.1" ]] && continue || true
		if [[ "$(dirname ${f})" = "usr/lib" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_BUILD_DIR}/${f}" || true
		fi
	done
fi
unset _bname

return 0

}


# *****************************************************************************
# Find the installed man pages, compress them, and adjust the file name in the
# so called database FILES list.
# *****************************************************************************

manpage_compress() {

local i=0
local f=""
#local lFile=""  # link file
#local mFile=""  # man file
#local manDir="" # man file directory

echo -n "m" >&${CONSOLE_FD}
for f in $(<FILES); do
	[[ -d "${TTYLINUX_BUILD_DIR}/${f}" ]] && continue || true
	if [[ -n "$(grep "^usr/share/man/man" <<<${f})" ]]; then
		i=$(($i + 1))
#
# The goal of this is to gzip any non-gziped man pages.  The problem is that
# some of those have more than one sym link to them; how to fixup all the
# symlinks?
#
#		lFile=""
#		mFile=$(basename ${f})
#		manDir=$(dirname ${f})
#		pushd "${TTYLINUX_BUILD_DIR}/${manDir}" >/dev/null 2>&1
#		if [[ -L ${mFile} ]]; then
#			lFile="${mFile}"
#			mFile="$(readlink ${lFile})"
#		fi
#		if [[	x"${mFile%.gz}"  = x"${mFile}" && \
#			x"${mFile%.bz2}" = x"${mFile}" ]]; then
#			echo "zipping \"${mFile}\""
#			gzip "${mFile}"
#			if [[ -n "${lFile}" ]]; then
#				rm --force "${lFile}"
#				ln --force --symbolic "${mFile}.gz" "${lFile}"
#			fi
#			sed --in-place "${TTYLINUX_BUILD_DIR}/BUILD/FILES" \
#				--expression="s|${mFile}$|${mFile}.gz|"
#		fi
#		popd >/dev/null 2>&1
	fi
done
[[ ${#i} -eq 1 ]] && echo -n "___${i}." >&${CONSOLE_FD}
[[ ${#i} -eq 2 ]] && echo -n  "__${i}." >&${CONSOLE_FD}
[[ ${#i} -eq 3 ]] && echo -n   "_${i}." >&${CONSOLE_FD}
[[ ${#i} -eq 4 ]] && echo -n    "${i}." >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# Collect the installed files into an as-built packge.
# *****************************************************************************

package_collect() {

# Save the list of files actually installed into build-root/
#
cp --force FILES "${TTYLINUX_BUILD_DIR}/usr/share/ttylinux/pkg-$1-FILES"
rm --force FILES # All done with the FILES file.

# Make the binary package: make a tarball of the files that is specified in the
# package configuration; this is found in "${TTYLINUX_PKGCFG_DIR}/$1/files".
#
echo -n "p." >&${CONSOLE_FD}

# This is tricky.  First make "${TTYLINUX_VAR_DIR}/files" from the contents of
# "${TTYLINUX_PKGCFG_DIR}/$1/files".  Then make the binary package from the
# list in "${TTYLINUX_VAR_DIR}/files".
#
if [[ -f "${TTYLINUX_PKGCFG_DIR}/$1/files-${TTYLINUX_CPU}" ]]; then
	package_list_make "${TTYLINUX_PKGCFG_DIR}/$1/files-${TTYLINUX_CPU}"
else
	package_list_make "${TTYLINUX_PKGCFG_DIR}/$1/files"
fi
cd ..
uTarBall="${TTYLINUX_PKGBIN_DIR}/$1-${TTYLINUX_CPU}.tar"
cTarBall="${TTYLINUX_PKGBIN_DIR}/$1-${TTYLINUX_CPU}.tbz"
tar --create \
	--file="${uTarBall}" \
	--files-from="${TTYLINUX_VAR_DIR}/files" \
	--no-recursion
bzip2 --force "${uTarBall}"
mv --force "${uTarBall}.bz2" "${cTarBall}"
unset uTarBall
unset cTarBall
cd BUILD
rm --force "${TTYLINUX_VAR_DIR}/files" # Remove the temporary file.

echo -n "c" >&${CONSOLE_FD}
pkg_clean # Call function pkg_clean from "bld-$1.sh".

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
build_spec_show    || exit 1

if [[ $# -gt 0 ]]; then
	# "$1" may be unbound so hide it in this if statement.
	# Reset the package list, if so specified.
	[[ -n "$1" ]] && TTYLINUX_PACKAGES="$1"
fi

if [[ ! -d "${TTYLINUX_BUILD_DIR}/BUILD" ]]; then
	echo "E> The build directory does NOT exist." >&2
	echo "E>      ${TTYLINUX_BUILD_DIR}/BUILD" >&2
	exit 1
fi

if [[ -z "${TTYLINUX_PACKAGES}" ]]; then
	echo "E> No packages to build.  How did you do that?" >&2
	exit 1
fi


# *****************************************************************************
# Main Program
# *****************************************************************************

echo ""
echo "##### START cross-building packages"
echo "g - getting the source and configuration packages"
echo "b - building and installing the package into build-root"
echo "f - finding installed files"
echo "m - looking for man pages to compress"
echo "p - creating ttylinux-installable package"
echo "c - cleaning"
echo ""

pushd "${TTYLINUX_BUILD_DIR}/BUILD" >/dev/null 2>&1

if [[ $(ls -1 | wc -l) -ne 0 ]]; then
	echo "BUILD directory is not empty:"
	ls -l
	echo ""
fi

#trap "rm --force --recursive ${TTYLINUX_BUILD_DIR}/BUILD/"* EXIT

T1P=${SECONDS}

for p in ${TTYLINUX_PACKAGES}; do

	t1=${SECONDS}

	echo -n "${p} ";
	for ((i=(28-${#p}) ; i > 0 ; i--)); do echo -n "."; done
	echo -n " ";

	exec 4>&1    # Save stdout at fd 4.
	CONSOLE_FD=4 #

	if [[ -d "${TTYLINUX_PKGCFG_DIR}/$p" ]]; then
		rm --force "${TTYLINUX_VAR_DIR}/log/$p.log"
		package_xbuild  "${p}" >>"${TTYLINUX_VAR_DIR}/log/$p.log" 2>&1
		manpage_compress       >>"${TTYLINUX_VAR_DIR}/log/$p.log" 2>&1
		package_collect "${p}" >>"${TTYLINUX_VAR_DIR}/log/$p.log" 2>&1
	else
		echo -n "(no pkg-cfg)" >&${CONSOLE_FD}
	fi

	exec >&4     # Set fd 1 back to stdout.
	CONSOLE_FD=1 #

	if [[ -d "${TTYLINUX_PKGCFG_DIR}/$p" ]]; then
		echo -n " ... DONE ["
		t2=${SECONDS}
		mins=$(((${t2}-${t1})/60))
		secs=$(((${t2}-${t1})%60))
		[[ ${#mins} -eq 1 ]] && echo -n " "; echo -n "${mins} minutes "
		[[ ${#secs} -eq 1 ]] && echo -n " "; echo -n "${secs} seconds"
		echo "]"
	else
		echo " ...... SKIPPED"
	fi

done

T2P=${SECONDS}
echo "=> $(((${T2P}-${T1P})/60)) minutes $(((${T2P}-${T1P})%60)) seconds"
echo ""

#trap - EXIT

if [[ $(ls -1 | wc -l) -ne 0 ]]; then
	echo "BUILD directory is not empty:"
	ls -l
	echo ""
fi

popd >/dev/null 2>&1

echo "##### DONE cross-building packages"


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
