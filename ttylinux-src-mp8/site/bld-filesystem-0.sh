#!/bin/bash
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "site file system pre build"
source ./ttylinux-config.sh
if [[ "${TTYLINUX_CLASS}" = "ws" ]]; then
	cp --verbose \
		site/root_extras.tbz \
		pkg-bin/root_extras-nopackage-${TTYLINUX_CPU}.tbz
fi
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
