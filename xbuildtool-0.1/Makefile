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
#	$RCSfile: Makefile,v $
#	$Revision: 1.9 $
#	$Date: 2010/12/21 22:09:40 $
#
# PROGRAM INFORMATION
#
#	Developed by:	xbuildtool project
#	Developer:	Douglas Jerome, drj, <douglas@ttylinux.org>
#
# FILE DESCRIPTION
#
#	This is a top-level makefile used in making an xbuildtool
#	cross-development tool chain for ttylinux distributions.
#
# CHANGE LOG
#
#	20feb11	drj	Finished miscellaneous changes for the first release.
#	01jan11	drj	Re-wrote ttylinux cross-tools Makefile for xbuildtool.
#	21dec10	drj	Stupid comment changes.
#	20dec10	drj	Added a mipsel cross-tool chain.
#	10oct10	drj	Removed experimental RTAI support.
#	12apr10	drj	Removed the TIMECMD.
#	03mar10	drj	Removed the arm and i486 targets.
#	20aug09	drj	Added the x86_64 cross-tool chain.
#	22jul09	drj	Added the arm-eabi and arnv5l cross-tool chain.
#	23dec08	drj	Added the i686 cross-tool chain.
#	22nov08	drj	Changed the names of some cleaning targets.
#	13nov08	drj	Replace time with macro TIMECMD.
#	09nov08	drj	Fixed "make clean" not to remove downloaded source.
#	08nov08	drj	Added host-base tool chain proxy.
#	07nov08	drj	Converted to ttylinux usage.
#	13sep07	drj	Original file creation.
#
# *****************************************************************************


# *****************************************************************************
# Make Targets
# *****************************************************************************

.PHONY:	help setup clean dload
.PHONY: armv5tej-gnueabi mipsel-gnu mipsel-uclibc
.PHONY: powerpc-gnu i486-gnu i686-gnu x86_64-gnu

help:
	@echo ""
	@echo "Make a ttylinux cross-development tool chain."
	@echo ""
	@echo "make setup ... Do this before using any of the other make"
	@echo "               commands.  This needs to be done first, and"
	@echo "               only one time."
	@echo ""
	@echo "make mipsel-uclibc ........ Make the ttylinux em-malta_lv-mipsel"
	@echo "                            target cross-development tool chain."
	@echo ""
	@echo "make armv5tej-2.9-gnueabi ... Make the ttylinux"
	@echo "                              sm-integrator_cp-armv5tej target"
	@echo "                              cross-development tool chain."
	@echo ""
	@echo "make i486-2.9-gnu ......... Make the ttylinux sm-pc-i486 target"
	@echo "                            cross-development tool chain."
	@echo ""
	@echo "make mipsel-2.9-gnu ....... Make the ttylinux sm-malta_lv-mipsel"
	@echo "                            target cross-development tool chain."
	@echo ""
	@echo "make i486-2.13-gnu ........ Make the ttylinux ut|ws-pc-i486"
	@echo "                            target cross-development tool chain."
	@echo ""
	@echo "make i686-2.13-gnu ........ Make the ttylinux ut|ws-pc-i686"
	@echo "                            target cross-development tool chain."
	@echo ""
	@echo "make x86_64-2.13-gnu ...... Make the ttylinux ut|ws-pc-x86_64"
	@echo "                            target cross-development tool chain."
	@echo ""
	@echo "make powerpc-2.13-gnu ..... Make the ttylinux"
	@echo "                            ut_ws-macintosh_g4-powerpc-ut|ws"
	@echo "                            target cross-development tool chain."
	@echo ""

setup:
	@./configure

clean:	xbt-build-config.sh
	@scripts/build-toolchain.sh "clean"

dload:	xbt-build-config.sh
	@scripts/build-toolchain.sh "download"

mipsel-uclibc:
	rm -f xbt-build-config.sh
	cp config/ttylinux-mipsel-uclibc.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

armv5tej-2.9-gnueabi:
	rm -f xbt-build-config.sh
	cp config/ttylinux-armv5tej-2.9-gnueabi.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

i486-2.9-gnu:
	rm -f xbt-build-config.sh
	cp config/ttylinux-i486-2.9-gnu.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

mipsel-2.9-gnu:
	rm -f xbt-build-config.sh
	cp config/ttylinux-mipsel-2.9-gnu.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

i486-2.13-gnu:
	rm -f xbt-build-config.sh
	cp config/ttylinux-i486-2.13-gnu.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

i686-2.13-gnu:
	rm -f xbt-build-config.sh
	cp config/ttylinux-i686-2.13-gnu.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

x86_64-2.13-gnu:
	rm -f xbt-build-config.sh
	cp config/ttylinux-x86_64-2.13-gnu.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh

powerpc-2.13-gnu:
	rm -f xbt-build-config.sh
	cp config/ttylinux-powerpc-2.13-gnu.cfg xbt-build-config.sh
	./scripts/build-toolchain.sh


# end of Makefile
