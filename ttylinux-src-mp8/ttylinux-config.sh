#!bin/bash


# $RCSfile:$
# $Revision:$
# $Date:$


# *****************************************************************************
#
# ttylinux-config.sh
#
# This file is used to specify the configuration of the ttylinux build process.
#
# There are several combinations of platform, CPU and cross-development tool
# chain.  A Linux cross-development tool chain is partly defined by its C
# library, libc, and Linux kernel version.  The list below shows the working
# combinations for this source distribution of ttylinux.
#
# TTYLINUX_PLATFORM  TTYLINUX_CPU  TTYLINUX_CLASS   libc and Linux versions
# -----------------  ------------  --------------   ---------------------------
# WRTU54G-TM         mips          em (EMbedded)    uClibc-0.9.31 linux-2.6.36.4
# Malta CoreLV       mips          sm (SMall)       glibc-2.9     linux-2.6.34.6
# Integrator CP      armv5tej      sm (SMall)       glibc-2.9     linux-2.6.34.6
# PC                 i486          sm (SMall)       glibc-2.9     linux-2.6.34.6
# PC                 i486          ut (UTility)     glibc-2.13    linux-2.6.38.1
# PC                 i686          ut (UTility)     glibc-2.13    linux-2.6.38.1
# PC                 x86_64        ut (UTility)     glibc-2.13    linux-2.6.38.1
# Beagle Board XP    armv7         ut (UTility)     glibc-2.13    linux-2.6.38.1
# Macintosh G4       powerpc       ut (UTility)     glibc-2.13    linux-2.6.38.1
# PC                 i486          ws (WorkStation) glibc-2.13    linux-2.6.38.1
# PC                 i686          ws (WorkStation) glibc-2.13    linux-2.6.38.1
# PC                 x86_64        ws (WorkStation) glibc-2.13    linux-2.6.38.1
# Macintosh G4       powerpc       ws (WorkStation) glibc-2.13    linux-2.6.38.1
#
# About the classification of ttylinux, TTYLINUX_CLASS:
#
# NOTE -- Yes, the TTYLINUX_CLASS selections are hysterical: calling the ws
#         system a Work Station is ridiculous.
#
# TTYLINUX_CLASS  ttylinux system description and goals
# --------------  --------------------------------------------------------
#             em  uClib, busybox, static /dev, kernel and file system fit in 8MB
#             sm  Glibc, busybox, static /dev, 8MB file system
#             ut  Glibc, busybox, udev, 24 MB file system
#             ws  Glibc, busybox, some Gnu/Other Utils, udev, Alsa, Gcc
#
# The value of TTYLINUX_CLASS partly determines which cross-development tool
# chain is used to build the system, which in turn determines the libc and
# Linux kernel versions.  Older versions of Glibc and Linux are smaller than
# newer versions; this is the only reason ttylinux uses the older versions.
#
# *****************************************************************************


# ttylinux target specification
# -----------------------------
#
# Select the ttylinux target to build by making it be the last TTYLINUX_TARGET
# definition in this list, or at least be the only one not a comment.
#
#TTYLINUX_TARGET="em-wrtu54g_tm-mipsel"		# em - Smaller System
#TTYLINUX_TARGET="sm-pc-i486"			# sm - Small System
#TTYLINUX_TARGET="sm-integrator_cp-armv5tej"	# sm - Small System
#TTYLINUX_TARGET="sm-malta_lv-mipsel"		# sm - Small System
#TTYLINUX_TARGET="ut-pc-i486"			# ut - Medium System
#TTYLINUX_TARGET="ut-pc-i686"			# ut - Medium System
#TTYLINUX_TARGET="ut-pc-x86_64"			# ut - Medium System
#TTYLINUX_TARGET="ut-beagle_xm-armv7"		# ut - Medium System
#TTYLINUX_TARGET="ut-macintosh_g4-powerpc"	# ut - Medium System
#TTYLINUX_TARGET="ws-pc-i486"			# ws - Larger System
#TTYLINUX_TARGET="ws-pc-i686"			# ws - Larger System
TTYLINUX_TARGET="ws-pc-x86_64"			# ws - Larger System
#TTYLINUX_TARGET="ws-macintosh_g4-powerpc"	# ws - Larger System


# ttylinux distribution attributes
# --------------------------------
#
# TTYLINUX_FSI_SIZE
#
#      File system image size, in megabytes, wherein a megabyte is measured as
#      1024x1024 bytes.  If the value here is too low it will be fixed below.
#      *** See note [1] below.
#
# TTYLINUX_STRIP_BINS
#
#      Whether or not to strip libraries and executable files.  Some binaries
#      are stripped as they are installed by default from the source
#      installation.
#
# TTYLINUX_KERNEL
#
#      This variable is used to specify your own custom Linux kernel for
#      ttylinux.  Give a value to TTYLINUX_KERNEL below, then you *must* have:
#      => appropriate Linux configuration file
#      => Linux kernel source file
#         ${TTYLINUX_DIR}/site/<platform>/kernel-${TTYLINUX_KERNEL}.cfg
#         ${TTYLINUX_DIR}/site/<platform>/Linux-${TTYLINUX_KERNEL}.tar.bz2
#
TTYLINUX_FSI_SIZE="4"     # File system image size, in MB (1024x1024). Note[1]
TTYLINUX_STRIP_BINS="yes" # Whether to strip libraries and executable files.
TTYLINUX_KERNEL=""        # Linux kernel override; leave blank for normal build.
#
# Notes:
# [1] - The file system size has a lower bound; the lower bound is set and used
#       to correct TTYLINUX_FSI_SIZE.  You can find that process in this file;
#       it is several steps after this note.


# ttylinux build process
# ----------------------
#
# TTYLINUX_SITE
#
#      Whether or not to invoke the site scripts in the site directory.  Set
#      this variable to anything other than "on" to disable the site scripts.
#      The site scripts are called from the ttylinue Makefile before and after
#      certain steps inthe ttylinux build process.
#
#      make command  pre command site script       post command site script
#      ------------  ----------------------------  ----------------------------
#      make clean    site/bld-clean-0.sh all       site/bld-clean-1.sh all
#      make kclean   site/bld-clean-0.sh kernel    site/bld-clean-1.sh kernel
#      make pclean   site/bld-clean-0.sh packages  site/bld-clean-1.sh packages
#      make init     site/bld-init-0.sh            site/bld-init-1.sh
#      make pkgs     site/bld-packages-0.sh        site/bld-packages-1.sh
#      make kernel   site/bld-kernel-0.sh          site/bld-kernel-1.sh
#      make fsys     site/bld-filesystem-0.sh      site/bld-filesystem-1.sh
#      make iso      site/bld-iso-0.sh             site/bld-iso-1.sh
#
TTYLINUX_SITE="off" # Whether to invoke the site scripts.
TTYLINUX_SITE="on"  # Whether to invoke the site scripts.


# cross-development tool chain
# ----------------------------
#
# This specifies the grand-parent directory that has the cross-development tool
# chains' parent directories.
#
# Historical Note -- The normal place for this WAS the top-level ttylinux
#                    source distribution directory.
#
CROSSTOOLS_DIR="$(pwd)"    # Old Historical Value
CROSSTOOLS_DIR="$(pwd)/.." # New Convention


# download cache
# --------------
#
# This specifies the location of the download cache. This location is
# checked before any files are downloaded.
#
DOWNLOAD_CACHE_DIR=~/Downloads


# *****************************************************************************
# Changing anything below is not recommeded, unless a bug fix.
# *****************************************************************************

TTYLINUX_CLASS="${TTYLINUX_TARGET%%-*}"     # em, sm, ut, ws
TTYLINUX_PLATFORM="${TTYLINUX_TARGET%-*}"   #
TTYLINUX_PLATFORM="${TTYLINUX_PLATFORM#*-}" # hardware platform
TTYLINUX_CPU="${TTYLINUX_TARGET##*-}"       # cpu


# ttylinux directory path
# -----------------------
#
# If you change this I hope you know what you are doing, because I would not
# begin to guess why you would change this.
#
TTYLINUX_DIR="$(pwd)"


# ttylinux name
# -------------
#
TTYLINUX_NAME="maiko"	# This is where the distribution code name is  set.  It
			# should be different from  any  previous  release code
			# name but  be  the  same for all Platform-CPU variants
			# in a given release.


# ttylinux version
# ----------------
#
# Set the ttylinux version.
# Set a lower bound on the target system file system size.
#
fsLb=4
case "${TTYLINUX_CLASS}-${TTYLINUX_CPU}" in
	'em-mipsel')	fsLb=4  ; TTYLINUX_VERSION="0.2"  ;;
	'sm-i486')	fsLb=8  ; TTYLINUX_VERSION="9.10" ;;
	'sm-armv5tej')	fsLb=8  ; TTYLINUX_VERSION="9.10" ;;
	'sm-mipsel')	fsLb=8  ; TTYLINUX_VERSION="9.10" ;;
	'ut-i486')	fsLb=24 ; TTYLINUX_VERSION="12.6" ;;
	'ut-i686')	fsLb=24 ; TTYLINUX_VERSION="12.6" ;;
	'ut-x86_64')	fsLb=24 ; TTYLINUX_VERSION="12.6" ;;
	'ut-armv7')	fsLb=16 ; TTYLINUX_VERSION="12.6" ;;
	'ut-powerpc')	fsLb=24 ; TTYLINUX_VERSION="12.6" ;;
	'ws-i486')	fsLb=64 ; TTYLINUX_VERSION="12.6" ;;
	'ws-i686')	fsLb=64 ; TTYLINUX_VERSION="12.6" ;;
	'ws-x86_64')	fsLb=64 ; TTYLINUX_VERSION="12.6" ;;
	'ws-powerpc')	fsLb=64 ; TTYLINUX_VERSION="12.6" ;;
esac
if [[ ${TTYLINUX_FSI_SIZE} -lt ${fsLb} ]]; then TTYLINUX_FSI_SIZE=${fsLb}; fi
unset fsLb


# cross-development tool chain
# ----------------------------
#
# There are three parts to the ttylinux convention of defining and accessing
# a cross-development tool chain: 1) location of the tool chains, 2) specific
# tool chain, and 3) specific build options.
#
# 1) location of the tool chains
#
# As part of the convention of accessing the cross-development tool chain, the
# parent directory depends upon TTYLINUX_CLASS-TTYLINUX_CPU, as that represents
# the libc and Linux versions, and it will be at:
# ${CROSSTOOLS_DIR}/cross-tools-<libc_version>-<linux_version>/
#
case "${TTYLINUX_CLASS}-${TTYLINUX_CPU}" in
	'em-mipsel')	_libc_linux="0.9.31-2.6.36.4" ;;
	'sm-i486')	_libc_linux="2.9-2.6.34.6"    ;;
	'sm-armv5tej')	_libc_linux="2.9-2.6.34.6"    ;;
	'sm-mipsel')	_libc_linux="2.9-2.6.34.6"    ;;
	'ut-i486')	_libc_linux="2.13-2.6.38.1" ;;
	'ut-i686')	_libc_linux="2.13-2.6.38.1" ;;
	'ut-x86_64')	_libc_linux="2.13-2.6.38.1" ;;
	'ut-armv7')	_libc_linux="2.13-2.6.38.1" ;;
	'ut-powerpc')	_libc_linux="2.13-2.6.38.1" ;;
	'ws-i486')	_libc_linux="2.13-2.6.38.1" ;;
	'ws-i686')	_libc_linux="2.13-2.6.38.1" ;;
	'ws-x86_64')	_libc_linux="2.13-2.6.39.3" ;;
	'ws-powerpc')	_libc_linux="2.13-2.6.38.1" ;;
esac
XBT_DIR="${CROSSTOOLS_DIR}/cross-tools-${_libc_linux}"
unset CROSSTOOLS_DIR
unset _libc_linux
#
# 2) specific tool chain
#
# As part of the convention of accessing the cross-development tool chain, the
# specific cross-development tool chain name is the directory containing the
# tool chain; this directory is the GNU triplet name of the target, wherein
# the triplet is the form (quadruplet): cpu-vendor-kernel-system
#
case ${TTYLINUX_TARGET} in
	'em-wrtu54g_tm-mipsel')      _ct="mipsel-generic-linux-uclibc"    ;;
	'sm-malta_lv-mipsel')        _ct="mipsel-generic-linux-gnu"       ;;
	'sm-integrator_cp-armv5tej') _ct="armv5tej-generic-linux-gnueabi" ;;
	'sm-pc-i486')                _ct="i486-generic-linux-gnu"         ;;
	'ut-pc-i486')                _ct="i486-generic-linux-gnu"         ;;
	'ut-pc-i686')                _ct="i686-generic-linux-gnu"         ;;
	'ut-pc-x86_64')              _ct="x86_64-generic-linux-gnu"       ;;
	'ut-beagle_xm-armv7')        _ct="armv7-generic-linux-gnueabi"    ;;
	'ut-macintosh_g4-powerpc')   _ct="powerpc-generic-linux-gnu"      ;;
	'ws-pc-i486')                _ct="i486-generic-linux-gnu"         ;;
	'ws-pc-i686')                _ct="i686-generic-linux-gnu"         ;;
	'ws-pc-x86_64')              _ct="x86_64-generic-linux-gnu"       ;;
	'ws-macintosh_g4-powerpc')   _ct="powerpc-generic-linux-gnu"      ;;
esac
TTYLINUX_XBT="${_ct}"
unset _ct
#
# 3) specific build options
#
case ${TTYLINUX_TARGET} in
	'em-wrtu54g_tm-mipsel')      _bo="-march=4kc -mtune=4kc -Os"        ;;
	'sm-malta_lv-mipsel')        _bo="-march=mips32 -mtune=mips32 -Os"  ;;
	'sm-integrator_cp-armv5tej') _bo="-Os"                              ;;
	'sm-pc-i486')                _bo="-march=i486 -mtune=i486 -Os"      ;;
	'ut-pc-i486')                _bo="-march=i486 -mtune=i486 -Os"      ;;
	'ut-pc-i686')                _bo="-march=i686 -mtune=generic -Os"   ;;
	'ut-pc-x86_64')              _bo="-m64 -Os"                         ;;
	'ut-beagle_xm-armv7')        _bo="-march=armv7-a -mcpu=cortex-a8"   ;;
	'ut-macintosh_g4-powerpc')   _bo="-mcpu=powerpc -mtune=powerpc -Os" ;;
	'ws-pc-i486')                _bo="-march=i486 -mtune=i486 -Os"      ;;
	'ws-pc-i686')                _bo="-march=i686 -mtune=generic -Os"   ;;
	'ws-pc-x86_64')              _bo="-m64 -Os"                         ;;
	'ws-macintosh_g4-powerpc')   _bo="-mcpu=powerpc -mtune=powerpc -Os" ;;
esac
TTYLINUX_CFLAGS="${_bo}"
unset _bo


# Make a new variable describing the ttylinux version and system.
#
TTYLINUX_TARGET_TAG="${TTYLINUX_VERSION}-${TTYLINUX_CPU}-${TTYLINUX_PLATFORM}"


# Debug *****
# echo "TTYLINUX_TARGET ....... ${TTYLINUX_TARGET}"
# echo "TTYLINUX_FSI_SIZE ..... ${TTYLINUX_FSI_SIZE}"
# echo "TTYLINUX_STRIP_BINS ... ${TTYLINUX_STRIP_BINS}"
# echo "TTYLINUX_KERNEL ....... \"${TTYLINUX_KERNEL}\""
# echo "TTYLINUX_SITE ......... ${TTYLINUX_SITE}"
# echo "TTYLINUX_DIR .......... ${TTYLINUX_DIR}"
# echo "TTYLINUX_PLATFORM ..... ${TTYLINUX_PLATFORM}"
# echo "TTYLINUX_CPU .......... ${TTYLINUX_CPU}"
# echo "TTYLINUX_CLASS ........ ${TTYLINUX_CLASS}"
# echo "TTYLINUX_NAME ......... ${TTYLINUX_NAME}"
# echo "TTYLINUX_VERSION ...... ${TTYLINUX_VERSION}"
# echo "XBT_DIR ............... ${XBT_DIR}"
# echo "TTYLINUX_XBT .......... ${TTYLINUX_XBT}"
# echo "TTYLINUX_CFLAGS ....... \"${TTYLINUX_CFLAGS}\""
# echo "TTYLINUX_TARGET_TAG ... ${TTYLINUX_TARGET_TAG}"
# exit 1


# end of file
