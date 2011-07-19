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
#	Developed by:	xbuildtool project
#	Developer:	Douglas Jerome, drj, <douglas@ttylinux.org>
#
# FILE DESCRIPTION
#
#	This script builds the cross-development GCC.
#
# CHANGE LOG
#
#	01jan11	drj	Initial version from ttylinux cross-tools.
#
# *****************************************************************************


# *****************************************************************************
# xbt_resolve_gcc_name
# *****************************************************************************

# Usage: xbt_resolve_gcc_name <string>
#
# Uses:
#      XBT_SCRIPT_DIR
#
# Sets:
#     XBT_GMP
#     XBT_GMP_MD5SUM
#     XBT_GMP_URL
#     XBT_MPFR
#     XBT_MPFR_MD5SUM
#     XBT_MPFR_URL
#     XBT_GCC
#     XBT_GCC_MD5SUM
#     XBT_GCC_URL

xbt_resolve_gcc_name() {

source ${XBT_SCRIPT_DIR}/gcc/gcc-versions.sh

XBT_GMP=""
XBT_GMP_MD5SUM=""
XBT_GMP_URL=""

XBT_MPFR=""
XBT_MPFR_MD5SUM=""
XBT_MPFR_URL=""

XBT_GCC=""
XBT_GCC_MD5SUM=""
XBT_GCC_URL=""

for (( i=0 ; i<${#_GCC[@]} ; i=(($i+1)) )); do
	if [[ "${1}" = "${_GCC[$i]}" ]]; then
		XBT_GMP="${_GMP[$i]}"
		XBT_GMP_MD5SUM="${_GMP_MD5SUM[$i]}"
		XBT_GMP_URL="${_GMP_URL[$i]}"
		XBT_MPFR="${_MPFR[$i]}"
		XBT_MPFR_MD5SUM="${_MPFR_MD5SUM[$i]}"
		XBT_MPFR_URL="${_MPFR_URL[$i]}"
		XBT_GCC="${_GCC[$i]}"
		XBT_GCC_MD5SUM="${_GCC_MD5SUM[$i]}"
		XBT_GCC_URL="${_GCC_URL[$i]}"
		i=${#_GCC[@]}
	fi
done

unset _GMP
unset _GMP_MD5SUM
unset _GMP_URL
unset _MPFR
unset _MPFR_MD5SUM
unset _MPFR_URL
unset _GCC
unset _GCC_MD5SUM
unset _GCC_URL

if [[ -z "${XBT_GCC}" ]]; then
	echo "E> Cannot resolve \"${1}\""
	return 1
fi

return 0

}


# *****************************************************************************
# xbt_build_gcc_stage1
# *****************************************************************************

# Build a cross-compiling GCC; this will be used to cross-compile GLIBC or
# uClibc for the target system, and also then be available to cross-build any
# target packages.
#
# The complete and final cross-compiling GCC cannot yet be built because it
# seems that the GCC build process builds a libgcc_s.so, and that needs the
# GLIBC or uClibc target header files and a cross-built libc.so with which
# libgcc_s.so is linked.  The libc target header files and cross-built libc.so
# are not yet available because the cross-compiling GCC is not yet built.
#
# Note:  libgcc_s.so is a cross-built target object code file; that is why it
#        can be linked with the cross-built target libc.so.  Since the cross-
#        compiling GCC itself is not a cross-built target program, it executes
#        on the host computer not target computer, libgcc_s.so is not linked
#        to the GCC cross-compiler.  The process of cross building software
#        with a cross-compiling GCC can take parts of libgcc_s.so and put them
#        into the software being cross-compiled.
#
# Libgcc_s.so may not be the only output from the build process that has the
# problem that is described above.  Libgcc.a and libgcc_eh.a may be similar.
#
# The first GCC-building step is to build a cross-compiling GCC while not
# building libgcc_s.so.  The GCC configuration option --disable-shared avoids
# bulding any shared objects.  The GCC cross-compiling-specific configuration
# options --with-newlib, --with-sysroot and --without-headers avoid using libc
# and avoid using any library header files during the build process.  Refer to
# http://gcc.gnu.org/install/configure.html for a description of these
# configuration options.  The --without-headers option might not be needed.
#
# This preliminary version of GCC will not need several other capabilities, and
# these other capabilities may not build without GLIBC or some other C library.
# The configuration options --disable-decimal-float, --disable-libada,
# --disable-libgomp, --disable-libmudflap, --disable-libssp, --disable-multilib
# and --disable-threads are used to avoid building these as yet unneeded GCC
# capabilities.
#
# Also, only the C language compiler is yet used.

# This preliminary cross compiler can be used to install Linux and libc header
# files and make some simple target library components of GLIBC or uClibc.

xbt_build_gcc_stage1() {

local msg

msg="Building ${XBT_GCC} Stage 1 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_35 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_GCC}.
#
xbt_src_get ${XBT_GCC}

# Get the GCC support packages.
#
if [[ -n "${XBT_GMP}" ]]; then
	tar xf ${XBT_SOURCE_DIR}/${XBT_GMP}.tar.bz2
	mv ${XBT_GMP} ${XBT_GCC}/gmp
fi
if [[ -n "${XBT_MPFR}" ]]; then
	tar xf ${XBT_SOURCE_DIR}/${XBT_MPFR}.tar.bz2
	mv ${XBT_MPFR} ${XBT_GCC}/mpfr
fi

cd ${XBT_GCC}
for p in ${XBT_PATCH_DIR}/${XBT_GCC}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p
cd ..

# Suppress the installation of libiberty.a; it is provided by binutils.
#
cd ${XBT_GCC}
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
cd ..

# The GCC documentation recommends building GCC outside of the source directory
# in a dedicated build directory.
#
rm -rf	"build-gcc"
mkdir	"build-gcc"
cd	"build-gcc"

# Configure GCC for building.
#
echo "# XBT_CONFIG **********"
../${XBT_GCC}/configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--target=${XBT_TARGET} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--enable-languages=c \
	--disable-decimal-float \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-multilib \
	--disable-shared \
	--disable-threads \
	--with-newlib \
	--with-sysroot=${XBT_XTARG_DIR} \
	--without-headers || exit 1

# Build GCC.
#
echo "# XBT_MAKE **********"
njobs=$((${ncpus} + 1))
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j ${njobs} || exit 1
unset njobs

# Install GCC.
#
echo "# XBT_INSTALL **********"
xbt_files_timestamp
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make install || exit 1
#
echo "# XBT_FILES **********"
xbt_files_find

# Move out and clean up.
#
cd ..
rm -rf "build-gcc"
rm -rf "${XBT_GCC}"

echo "done" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# xbt_build_gcc_stage2
# *****************************************************************************

xbt_build_gcc_stage2() {

# Build a more complete cross-compiling GCC, allowing the use of the libc
# header files and the crt1.o, crti.o and crtn.o object files.  Libgcc_s.so
# will be built and the empty cross-built target libc.so will be linked with
# it, so this version of GCC is not the complete and final version.  Since this
# is not the final and complete GCC, several other GCC capabilities that are
# not yet needed are not built; they are the same as before and configure to
# not be in the build with --disable-libada, --disable-libgomp,
# --disable-libmudflap and --disable-libssp.
#
# Also, only the C language compiler is yet used.

local msg
local ENABLE_THREADS

msg="Building ${XBT_GCC} Stage 2 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_35 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_GCC}.
#
xbt_src_get ${XBT_GCC}

# Get the GCC support packages.
#
if [[ -n "${XBT_GMP}" ]]; then
	tar xf ${XBT_SOURCE_DIR}/${XBT_GMP}.tar.bz2
	mv ${XBT_GMP} ${XBT_GCC}/gmp
fi
if [[ -n "${XBT_MPFR}" ]]; then
	tar xf ${XBT_SOURCE_DIR}/${XBT_MPFR}.tar.bz2
	mv ${XBT_MPFR} ${XBT_GCC}/mpfr
fi

cd ${XBT_GCC}
for p in ${XBT_PATCH_DIR}/${XBT_GCC}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p
cd ..

# Suppress the installation of libiberty.a; it is provided by binutils.
#
cd ${XBT_GCC}
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
cd ..

# The GCC documentation recommends building GCC outside of the source directory
# in a dedicated build directory.
#
rm -rf	"build-gcc"
mkdir	"build-gcc"
cd	"build-gcc"

ENABLE_THREADS="--disable-threads"
[[ "${XBT_THREAD_MODEL}" = "nptl" ]] && ENABLE_THREADS="--enable-threads"

# Configure GCC for building.
#
echo "# XBT_CONFIG **********"
../${XBT_GCC}/configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--target=${XBT_TARGET} \
	--prefix=${XBT_XHOST_DIR}/usr \
	--enable-languages=c \
	--enable-shared \
	${ENABLE_THREADS} \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-multilib \
	--with-sysroot=${XBT_XTARG_DIR} || exit 1

# Build GCC.
#
echo "# XBT_MAKE **********"
njobs=$((${ncpus} + 1))
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j ${njobs} || exit 1
unset njobs

# Install GCC.
#
echo "# XBT_INSTALL **********"
xbt_files_timestamp
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make install || exit 1
#
echo "# XBT_FILES **********"
xbt_files_find

# Move out and clean up.
#
cd ..
rm -rf "build-gcc"
rm -rf "${XBT_GCC}"

echo "done" >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# xbt_build_gcc_stage3
# *****************************************************************************

xbt_build_gcc_stage3() {

# There now is a complete and final cross-built target libc, either GLIBC or
# uClibc; the header files and target libraries are installed; now configure
# and build a cross-compiling GCC with the complete and final cross-built
# target libc.
#
# The C, C99 and C++ language compilers can be built.
#
# Note:  Several capabilities are not built; these might be not applicable for
#        cross-build GCC or they may be wanted but fail to build, or there may
#        be no good reason for not building them.  They are avoided with
#        --disable-libada, --disable-libgomp, --disable-libmudflap and
#        --disable-libssp.

local msg
local ENABLE_THREADS
local ENABLE_LANGUAGES
local ENABLE__CXA_ATEXIT

msg="Building ${XBT_GCC} Stage 3 "
echo -n "${msg}"          >&${CONSOLE_FD}
xbt_print_dots_35 ${#msg} >&${CONSOLE_FD}
echo -n " "               >&${CONSOLE_FD}

# Find, uncompress and untarr ${XBT_GCC}.
#
xbt_src_get ${XBT_GCC}

# Get the GCC support packages.
#
if [[ -n "${XBT_GMP}" ]]; then
	tar xf ${XBT_SOURCE_DIR}/${XBT_GMP}.tar.bz2
	mv ${XBT_GMP} ${XBT_GCC}/gmp
fi
if [[ -n "${XBT_MPFR}" ]]; then
	tar xf ${XBT_SOURCE_DIR}/${XBT_MPFR}.tar.bz2
	mv ${XBT_MPFR} ${XBT_GCC}/mpfr
fi

cd ${XBT_GCC}
for p in ${XBT_PATCH_DIR}/${XBT_GCC}-*.patch; do
	if [[ -f "${p}" ]]; then patch -Np1 -i "${p}"; fi
done; unset p
cd ..

# Suppress the installation of libiberty.a; it is provided by binutils.
#
cd ${XBT_GCC}
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
cd ..

# Configure GCC for using only /lib and NOT /lib64 for x86_64.
#
cd "${XBT_GCC}"
if [[ "${XBT_LINUX_ARCH}" = "x86_64" ]]; then
	# Change GCC to use /lib   for 64-bit stuff, not /lib64
	# Change GCC to use /lib32 for 32-bit stuff, not /lib
	sed -e 's|/lib/ld-linux.so.2|/lib32/ld-linux.so.2|' \
		-i gcc/config/i386/linux64.h
	sed -e 's|/lib64/ld-linux-x86-64.so.2|/lib/ld-linux-x86-64.so.2|' \
		-i gcc/config/i386/linux64.h
	sed -e 's|../lib64|../lib|' \
		-i gcc/config/i386/t-linux64
	sed -e 's|../lib)|../lib32)|' \
		-i gcc/config/i386/t-linux64
	# On x86_64, unsetting the multilib spec for GCC ensures that it won't
	# attempt to link against libraries on the host.
	for file in $(find gcc/config -name t-linux64) ; do
		cp ${file} ${file}.orig
		sed '/MULTILIB_OSDIRNAMES/d' ${file}.orig >${file}
	done
fi
cd ..

# The GCC documentation recommends building GCC outside of the source directory
# in a dedicated build directory.
#
rm -rf	"build-gcc"
mkdir	"build-gcc"
cd	"build-gcc"

ENABLE_LANGUAGES="--enable-languages=c"
ENABLE__CXA_ATEXIT=""
if [[ "${XBT_C_PLUS_PLUS}" = "yes" ]]; then
	ENABLE_LANGUAGES="--enable-languages=c,c++"
	ENABLE__CXA_ATEXIT="--enable-__cxa_atexit"
fi

ENABLE_THREADS="--enable-threads=no"
[[ "${XBT_THREAD_MODEL}" = "nptl" ]] && ENABLE_THREADS="--enable-threads=posix"

# Configure GCC for building.
#
# -enable-shared --enable-threads=posix --enable-__cxa_atexit:
# These commands are required to build the C++ libraries to published standards.
#
# --enable-clocale=gnu:
# This command is a failsafe for incomplete locale data.
#
echo "# XBT_CONFIG **********"
../${XBT_GCC}/configure \
	--build=${XBT_HOST} \
	--host=${XBT_HOST} \
	--target=${XBT_TARGET} \
	--prefix=/usr \
	${ENABLE_LANGUAGES} \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-long-long \
	--enable-shared \
	${ENABLE_THREADS} \
	${ENABLE__CXA_ATEXIT} \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-multilib \
	--with-sysroot=${XBT_XTARG_DIR} || exit 1

# Build GCC.
#
echo "# XBT_MAKE **********"
njobs=$((${ncpus} + 1))
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} make -j ${njobs} || exit 1
unset njobs

# Install GCC.
#
echo "# XBT_INSTALL **********"
xbt_files_timestamp
#
PATH=${XBT_XHOST_DIR}/usr/bin:${PATH} \
make DESTDIR=${XBT_XHOST_DIR} install || exit 1
ln -s "${XBT_TARGET}-gcc" "${XBT_XHOST_DIR}/usr/bin/${XBT_TARGET}-cc"
#
echo "# XBT_FILES **********"
xbt_files_find

# Move out and clean up.
#
cd ..
rm -rf "build-gcc"
rm -rf "${XBT_GCC}"

echo "done [${XBT_GCC} is complete]" >&${CONSOLE_FD}

return 0

}


# end of file
