#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2013 OpenWrt.org

set -ex
[ $# -eq 5 ] || {
    echo "SYNTAX: $0 <file> <kernel size> <rootfs size> <image path> <device name>"
    exit 1
}

OUTPUT="$1"
KERNEL_SIZE="$2"
ROOTFS_SIZE="$3"
KDIR="$4"
DEVICE_NAME="$5"

head=4
sect=63

set $(ptgen -o $OUTPUT -h $head -s $sect -l 1024 -t c -p 1M -t 83 -p ${KERNEL_SIZE}M -t 83 -p ${ROOTFS_SIZE}M)

KERNEL_OFFSET="$(($3 / 512))"
KERNEL_SIZE="$(($4 / 512))"
ROOTFS_OFFSET="$(($5 / 512))"
ROOTFS_SIZE="$(($6 / 512))"

# keep the partition table image for Nuwriter
cp -a $OUTPUT $KDIR/$DEVICE_NAME.pt

# 0x400
#dd bs=512 if=${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header.bin of="$OUTPUT" seek=2 conv=notrunc
# 0x20000
#dd bs=512 if=${STAGING_DIR_IMAGE}/bl2.dtb of="$OUTPUT" seek=256 conv=notrunc
# 0x30000
#dd bs=512 if=${STAGING_DIR_IMAGE}/bl2.bin of="$OUTPUT" seek=384 conv=notrunc
# 0x40000
#dd bs=512 if=${STAGING_DIR_IMAGE}/uboot-env.bin-sdcard of="$OUTPUT" seek=512 conv=notrunc
# 0xC0000
#dd bs=512 if=${STAGING_DIR_IMAGE}/fip.bin-sdcard of="$OUTPUT" seek=1536 conv=notrunc
# 0x2c0000
#dd bs=512 if=${STAGING_DIR_IMAGE}/Image.dtb of="$OUTPUT" seek=5632 conv=notrunc
# 0x300000
dd bs=512 if=${KDIR}/${DEVICE_NAME}-uImage of="$OUTPUT" seek="$KERNEL_OFFSET" conv=notrunc
# root fs
dd bs=512 if=${KDIR}/root.ext4 of="$OUTPUT" seek="$ROOTFS_OFFSET" conv=notrunc
