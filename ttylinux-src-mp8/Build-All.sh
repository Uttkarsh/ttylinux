#!/bin/bash

K_TARGETS="\
em-wrtu54g_tm-mipsel \
sm-integrator_cp-armv5tej \
sm-malta_lv-mipsel \
sm-pc-i486 \
ut-beagle_xm-armv7 \
ut-macintosh_g4-powerpc \
ut-pc-i486 \
ut-pc-i686 \
ut-pc-x86_64 \
ws-macintosh_g4-powerpc \
ws-pc-i486 \
ws-pc-i686 \
ws-pc-x86_64"

t1=${SECONDS}

sed -e "s/^TTYLINUX_TARGET=/#TTYLINUX_TARGET=/" -i ttylinux-config.sh

for t in ${K_TARGETS}; do
	#
	sed -e "s/^TTYLINUX_TARGET=/#TTYLINUX_TARGET=/" -i ttylinux-config.sh
	sed -e "s/^#TTYLINUX_TARGET=\"${t}\"/TTYLINUX_TARGET=\"${t}\"/" \
		-i ttylinux-config.sh
	#
	make clean
	make dload
	make dist
	cp -f img/*.iso site/dump
	cp -f img/*.tar.bz2 site/dump
	#
	if [[					\
	"${t}" = "sm-pc-i486" ||		\
	"${t}" = "ut-pc-i686" ||		\
	"${t}" = "ut-pc-x86_64" ||		\
	"${t}" = "ut-macintosh_g4-powerpc"	\
	]]; then
		make PACKAGE=calc-2.12.4.2 calc-2.12.4.2
		make PACKAGE=thttpd-2.25b thttpd-2.25b
		make PACKAGE=ntfs-3g-2010.10.2 ntfs-3g-2010.10.2
		cp pkg-bin/calc-2.12.4.2*.tbz     site/dump
		cp pkg-bin/thttpd-2.25b*.tbz      site/dump
		cp pkg-bin/ntfs-3g-2010.10.2*.tbz site/dump
	fi
	#
	make clean
	#
done

sed -e "s/^TTYLINUX_TARGET=/#TTYLINUX_TARGET=/" -i ttylinux-config.sh

t2=${SECONDS}

_secs=$((${t2} - ${t1}))
_hour=$(({$_secs} / 3600 ))
_secs=$(({$_secs} % 3600 ))
_mins=$(({$_secs} / 60 ))
_secs=$(({$_secs} % 60 ))

echo ""
echo "All done building."
printf "=> %2d hours, %2d minutes, %2d seconds" ${_hour} ${_mins} ${_secs}

exit 0
