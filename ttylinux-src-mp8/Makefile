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
# FILE NAME
#
#	$RCSfile: Makefile,v $
#	$Revision: 1.12 $
#	$Date: Fri Apr 22 14:11:01 MST 2011$
#
# PROGRAM INFORMATION
#
#	Developed by:	ttylinux project
#	Developer:	Douglas Jerome, drj, <douglas@ttylinux.org>
#
# FILE DESCRIPTION
#
#	This is the makefile used in making a ttylinux distribution.
#
# CHANGE LOG
#
#	22apr11	drj	Added the "media" target.
#	03mar11	drj	Changed the "iso" target to "boot".
#	01jan11	drj	Miscellaneous fussing.
#	11dec10	drj	Added the use of TTYLINUX_SITE.
#	11dec10	drj	Added calls to site pre and post build scripts.
#	11dec10	drj	Shortened script names.
#	11dec10	drj	Removed the loader.  Changed how clean works.
#	17nov10	drj	Changed the "make dist" order.
#	13nov10	drj	Changed ttylinux.dist-config.sh to ttylinux-config.sh.
#	13nov10	drj	Added bcfg-stnd and bcfg-suid targets.
#	09oct10	drj	Added the "dload" target and miscellaneous fussing.
#	12may10	drj	Changed "source" shell command to "." for non-bash use.
#	10apr10	drj	Changed "false" to "exit 1".
#	30mar10	drj	Changed the "bootcd" target to be "iso".
#	07mar10	drj	"make stat" reports the build configuration.
#	07mar10	drj	Gave a thurough workover.
#	04mar10	drj	Updated for multiple architectures and cross-tools.
#	06dec09	drj	Corrected misspellings.
#	22aug09	drj	Added the "add-on" target.
#	08aug09	drj	Added the "burncd" target.
#	19jul09	drj	Added the "list" target.
#	25oct08	drj	Added "false" to make correct error paths.
#	13oct08	drj	Removed prefix time commands.
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
# Macro Definitions                                                           #
# *************************************************************************** #

# -- Single-Package Target
#
PACKAGE=""


# *****************************************************************************
# Make Targets
# *****************************************************************************

.PHONY: help
.PHONY: clean kclean pclean list stat mount umount bcfg-stnd bcfg-suid kcfg
.PHONY: is_build_coherent
.PHONY: add-on init pkgs kernel fsys boot dist
.PHONY: media burncd dload

# -----------------------------------------------------------------------------
# -- Default Target
# -----------------------------------------------------------------------------

help:
	@echo ""
	@echo "Make ttylinux.  Make command targets are:"
	@echo ""
	@echo "Make        Description"
	@echo "------      -----------"
	@echo "help        This message."
	@echo "clean       Remove the entire ttylinux build."
	@echo "kclean      Remove the ttylinux kernel build."
	@echo "pclean      Remove the ttylinux packages build."
	@echo "list        List the packages names and versions."
	@echo "stat        Report the status of the ttylinux build."
	@echo "mount       Mount the ttylinux file system image, if found."
	@echo "umount      Unmount the ttylinux file system image, if mounted."
	@echo "bcfg-stnd   \"make menuconfig\" for the normal busybox programs."
	@echo "bcfg-suid   \"make menuconfig\" for the suid busybox programs."
	@echo "kcfg        \"make menuconfig\" for the ttylinux target kernel."
	@echo "add-on      Build a ttylinux add-on package."
	@echo "init        Initialize for building ttylinux packages."
	@echo "pkgs        Build the ttylinux packages."
	@echo "kernel      Build the ttylinux target kernel."
	@echo "fsys        Create a ttylinux file system image."
	@echo "boot        Build the ttylinux boot file system."
	@echo "dist        Create a the entire ttylinux build."
	@echo "media       Put the ttylinux boot system onto appropriate media."
	@echo "burncd      Burn a ttylinux ISO to CD-ROM media."
	@echo "dload       Download source packages."
	@echo ""
	@echo "Examples"
	@echo "   \"make init\" initializes for building."
	@echo "   \"make fsys\" creates the file system image."
	@echo ""

# -----------------------------------------------------------------------------
# -- Housekeeping Targets
# -----------------------------------------------------------------------------

clean:	scripts/bld-clean.sh
	@if [ -f var/run/init ]; then					\
		echo "Remove the `cat var/run/init` built items.";	\
	else								\
		echo "Remove the built items.";				\
	fi
	@. ./ttylinux-config.sh;					\
	[ -f site/bld-clean-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-clean-0.sh all) || true
	@(scripts/bld-clean.sh all);					\
	if [ $$? -ne 0 ]; then						\
		echo "Clean FAILED.";					\
		exit 1;							\
	fi
	@. ./ttylinux-config.sh;					\
	[ -f site/bld-clean-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-clean-1.sh all) || true
	@rm -f var/run/init
	@rm -f var/run/pkgs
	@rm -f var/run/kernel
	@rm -f var/run/fsys
	@rm -f var/run/boot

kclean:	scripts/bld-clean.sh
	@if [ -f var/run/init ]; then					\
		echo "Remove the `cat var/run/init` kernel.";		\
	else								\
		echo "Remove the kernel.";				\
	fi
	@. ./ttylinux-config.sh;					\
	[ -f site/bld-clean-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-clean-0.sh kernel) || true
	@(scripts/bld-clean.sh kernel);					\
	if [ $$? -ne 0 ]; then						\
		echo "Clean FAILED.";					\
		exit 1;							\
	fi
	@. ./ttylinux-config.sh;					\
	[ -f site/bld-clean-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-clean-1.sh kernel) || true
	@rm -f var/run/kernel
	@rm -f var/run/fsys
	@rm -f var/run/boot

pclean:	scripts/bld-clean.sh
	@if [ -f var/run/init ]; then					\
		echo "Remove the `cat var/run/init` packages.";		\
	else								\
		echo "Remove the packages.";				\
	fi
	@. ./ttylinux-config.sh;					\
	[ -f site/bld-clean-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-clean-0.sh packages) || true
	@(scripts/bld-clean.sh packages);				\
	if [ $$? -ne 0 ]; then						\
		echo "Clean FAILED.";					\
		exit 1;							\
	fi
	@. ./ttylinux-config.sh;					\
	[ -f site/bld-clean-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-clean-1.sh packages) || true
	@rm -f var/run/init
	@rm -f var/run/pkgs
	@rm -f var/run/fsys
	@rm -f var/run/boot

find:	scripts/show-lostfiles.sh
	@(scripts/show-lostfiles.sh)

list:	scripts/show-listpackages.sh
	@(scripts/show-listpackages.sh)

stat:
	@. ./ttylinux-config.sh;					\
	t1=$${TTYLINUX_TARGET_TAG};					\
	if [ -f var/run/init ]; then					\
		t=`cat var/run/init`;					\
		if [ "$${t}" != "$${t1}" ]; then			\
			echo "";					\
			echo "Build MISMATCH.";				\
			echo "=> ttylinux-config.sh : $${t1}";		\
			echo "=> build initialized for   : $$t";	\
			echo "Did you change ttylinux-config.sh?";	\
			echo "Maybe \"make clean\" first.";		\
		fi							\
	else								\
		t="$${t1}";						\
	fi;								\
	echo "Report the status of the $$t ttylinux build."
	@(echo -n "> Build ";						\
	[ ! -f var/run/init ] && echo -n "NOT ";			\
	echo "Initialized")
	@(echo -n "> Packages ";					\
	[ ! -f var/run/pkgs ] && echo -n "NOT ";			\
	echo "Built")
	@(echo -n "> Kernel ";						\
	[ ! -f var/run/kernel ] && echo -n "NOT ";			\
	echo "Built")
	@(echo -n "> File System ";					\
	[ ! -f var/run/fsys ] && echo -n "NOT ";			\
	echo "Built")
	@(echo -n "> Boot File System ";				\
	[ ! -f var/run/boot ] && echo -n "NOT ";			\
	echo "Built")

mount:	scripts/sys-mount.sh
	@echo "Mount the ttylinux file system image."
	@(scripts/sys-mount.sh)

umount:	scripts/sys-umount.sh
	@echo "Unmount the ttylinux file system image."
	@(scripts/sys-umount.sh)

bcfg-stnd:	scripts/cfg-busybox.sh
	echo "Regenerate a busybox configuration."
	@(scripts/cfg-busybox.sh stnd)

bcfg-suid:	scripts/cfg-busybox.sh
	echo "Regenerate a busybox configuration."
	@(scripts/cfg-busybox.sh suid)

kcfg:	scripts/cfg-kernel.sh
	@(scripts/cfg-kernel.sh)

is_build_coherent:
	@t=`cat var/run/init`;						\
	. ./ttylinux-config.sh;						\
	echo "Building for $${TTYLINUX_TARGET_TAG}";			\
	if [ "$${t}" != "$${TTYLINUX_TARGET_TAG}" ]; then		\
		echo "=> Build already in progress for \"$$t\".";	\
		echo "=> Build MISMATCH.";				\
		echo "=> Did you change ttylinux-config.sh?";		\
		echo "=> Maybe \"make clean\" first.";			\
		exit 1;							\
	fi

var/run/init:
	@if [ ! -f var/run/init ]; then					\
		echo "Not initialized for building.";			\
		exit 1;							\
	fi

var/run/pkgs:
	@if [ ! -f var/run/pkgs ]; then					\
		echo "No packages are built.";				\
		exit 1;							\
	fi

var/run/fsys:
	@if [ ! -f var/run/fsys ]; then					\
		echo "The file system is not built.";			\
		exit 1;							\
	fi

var/run/kernel:
	@if [ ! -f var/run/kernel ]; then				\
		echo "The kernel is not built.";			\
		exit 1;							\
	fi

var/run/boot:
	@if [ ! -f var/run/boot ]; then					\
		echo "The boot file system is not built.";		\
		exit 1;							\
	fi

# -----------------------------------------------------------------------------
# -- Build Targets
# -----------------------------------------------------------------------------

${PACKAGE}:	scripts/bld-packages.sh var/run/init is_build_coherent
	@(scripts/bld-packages.sh ${PACKAGE})

add-on:	scripts/bld-addon.sh var/run/init is_build_coherent
	@(scripts/bld-addon.sh ${PACKAGE})

init:	scripts/bld-init.sh
	@. ./ttylinux-config.sh;					\
	if [ -f var/run/init ]; then					\
		t=`cat var/run/init`;					\
		echo "Already builing for $$t";				\
		echo "Maybe \"make clean\" first.";			\
		unset t;						\
		exit 1;							\
	fi;								\
	echo "Initialize the $${TTYLINUX_TARGET_TAG} ttylinux build.";	\
	[ -f site/bld-init-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-init-0.sh) || true;				\
	(scripts/bld-init.sh);						\
	if [ $$? -ne 0 ]; then						\
		echo "Initialize FAILED.";				\
		exit 1;							\
	fi;								\
	[ -f site/bld-init-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-init-1.sh) || true;				\
	echo "$${TTYLINUX_TARGET_TAG}" >var/run/init

pkgs:	scripts/bld-packages.sh var/run/init is_build_coherent
	@echo "Make the ttylinux packages.";				\
	. ./ttylinux-config.sh;						\
	rm -f var/run/pkgs;						\
	[ -f site/bld-packages-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] && \
		(site/bld-packages-0.sh) || true;			\
	(scripts/bld-packages.sh);					\
	if [ $$? -ne 0 ]; then						\
		echo "Build FAILED.";					\
		exit 1;							\
	fi;								\
	[ -f site/bld-packages-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] && \
		(site/bld-packages-1.sh) || true;			\
	touch var/run/pkgs

kernel:	scripts/bld-kernel.sh
	@echo "Make the ttylinux kernel.";				\
	. ./ttylinux-config.sh;						\
	rm -f var/run/kernel;						\
	[ -f site/bld-kernel-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-kernel-0.sh) || true;				\
	(scripts/bld-kernel.sh);					\
	if [ $$? -ne 0 ]; then						\
		echo "Kernel FAILED.";					\
		exit 1;							\
	fi;								\
	[ -f site/bld-kernel-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-kernel-1.sh) || true;				\
	touch var/run/kernel

fsys:	scripts/bld-filesystem.sh var/run/pkgs is_build_coherent
	@echo "Make ttylinux file system image.";			\
	. ./ttylinux-config.sh;						\
	rm -f var/run/fsys;						\
	[ -f site/bld-filesystem-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] && \
		(site/bld-filesystem-0.sh) || true;			\
	(scripts/bld-filesystem.sh);					\
	if [ $$? -ne 0 ]; then						\
		echo "File system FAILED.";				\
		exit 1;							\
	fi;								\
	[ -f site/bld-filesystem-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] && \
		(site/bld-filesystem-1.sh) || true;			\
	touch var/run/fsys

boot:	scripts/bld-boot.sh var/run/fsys var/run/kernel
	@echo "Make a ttylinux boot file system.";			\
	. ./ttylinux-config.sh;						\
	rm -f var/run/boot;						\
	[ -f site/bld-boot-0.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-boot-0.sh) || true;				\
	(scripts/bld-boot.sh);						\
	if [ $$? -ne 0 ]; then						\
		echo "Boot File System FAILED.";			\
		exit 1;							\
	fi;								\
	[ -f site/bld-boot-1.sh -a x"$${TTYLINUX_SITE}" = x"on" ] &&	\
		(site/bld-boot-1.sh) || true;				\
	touch var/run/boot

dist:	clean init pkgs kernel fsys boot

media:	scripts/bld-media.sh var/run/boot
	@echo "Make ttylinux media."
	@(scripts/bld-media.sh)

burncd:	scripts/bld-burncd.sh var/run/boot
	@echo "Make ttylinux CD-ROM media."
	@(scripts/bld-burncd.sh)

dload:	scripts/dload.sh
	@echo "Download ttylinux source packages."
	@(scripts/dload.sh)


# end of Makefile
