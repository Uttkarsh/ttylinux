echo "U-Boot Script [user.scr] Running : BeagleBoard ${beaglerev}"
mmc init
mmc rescan 0
setenv loadaddr 0x80300000
setenv bootargs console=ttyO2,115200n8 root=/dev/mmcblk0p2 rw
fatload mmc 0 ${loadaddr} uImage
bootm ${loadaddr}
