echo "U-Boot Script [boot.scr] Running : BeagleBoard ${beaglerev}"
mmc init
mmc rescan 0
setenv rdaddr 0x81600000
setenv loadaddr 0x80300000
setenv bootargs console=ttyO2,115200n8 vram=12MB omapfb.mode=dvi:1024x768MR-16@60 root=/dev/ram0 rw ramdisk_size=24576 enet
fatload mmc 0 ${rdaddr} ramdisk.gz
fatload mmc 0 ${loadaddr} uImage
bootm ${loadaddr} ${rdaddr}
