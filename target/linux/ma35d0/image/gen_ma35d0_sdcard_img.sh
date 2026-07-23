#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2013 OpenWrt.org

set -ex
[ $# -ge 6 ] || {
    echo "SYNTAX: $0 <file> <kernel size> <rootfs size> <image path> <device name> <dtb path> [data size]"
    exit 1
}

OUTPUT="$1"
KERNEL_SIZE="$2"
ROOTFS_SIZE="$3"
KDIR="$4"
DEVICE_NAME="$5"
DTB_PATH="$6"
DATA_SIZE="$7"

head=4
sect=63

if [ -n "$DATA_SIZE" ] && [ "$DATA_SIZE" -gt 0 ]; then
    # Read-only squashfs root (p3) + writable ext4 rootfs_data overlay (p4)
    set $(ptgen -o $OUTPUT -h $head -s $sect -l 1024 -t c -p 1M -t 83 -p ${KERNEL_SIZE}M -t 83 -p ${ROOTFS_SIZE}M -t 83 -p ${DATA_SIZE}M)
    DATA_OFFSET="$(($7 / 512))"
    DATA_PSIZE="$(($8 / 512))"
    ROOTFS_IMG="${KDIR}/root.squashfs"
else
    # Writable ext4 root (p3), no overlay (legacy layout)
    set $(ptgen -o $OUTPUT -h $head -s $sect -l 1024 -t c -p 1M -t 83 -p ${KERNEL_SIZE}M -t 83 -p ${ROOTFS_SIZE}M)
    ROOTFS_IMG="${KDIR}/root.ext4"
fi

KERNEL_OFFSET="$(($3 / 512))"
KERNEL_SIZE="$(($4 / 512))"
ROOTFS_OFFSET="$(($5 / 512))"
ROOTFS_SIZE="$(($6 / 512))"

# Diagnostics + guard: make it obvious in the build log which layout is used
# and fail loudly if the selected rootfs image is missing (e.g. squashfs not
# built), instead of writing a stale/wrong filesystem to p3.
echo "$(basename "$0"): DATA_SIZE='${DATA_SIZE}' ROOTFS_IMG='${ROOTFS_IMG}'"
[ -f "$ROOTFS_IMG" ] || {
    echo "ERROR: rootfs image '$ROOTFS_IMG' not found - check FILESYSTEMS / squashfs build"
    exit 1
}

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
# 0x2c0000 - device tree, read by u-boot via "mmc read fdt 0x1600 0x80".
# Embedded here so that sysupgrade/OTA can also refresh the DTB.
dd bs=512 if="${DTB_PATH}" of="$OUTPUT" seek=5632 conv=notrunc
# 0x300000
dd bs=512 if=${KDIR}/${DEVICE_NAME}-uImage of="$OUTPUT" seek="$KERNEL_OFFSET" conv=notrunc
# root fs
dd bs=512 if="${ROOTFS_IMG}" of="$OUTPUT" seek="$ROOTFS_OFFSET" conv=notrunc

# rootfs_data overlay: an empty ext4 labelled "rootfs_data" so that fstools
# mounts it as /overlay and OTA can preserve user settings across upgrades.
if [ -n "$DATA_SIZE" ] && [ "$DATA_SIZE" -gt 0 ]; then
    DATA_IMG="${KDIR}/${DEVICE_NAME}-rootfs_data.ext4"
    dd if=/dev/zero of="$DATA_IMG" bs=512 count="$DATA_PSIZE"
    mkfs.ext4 -F -q -L rootfs_data "$DATA_IMG"
    dd bs=512 if="$DATA_IMG" of="$OUTPUT" seek="$DATA_OFFSET" conv=notrunc
    # keep $DATA_IMG so the NuWriter pack step (IMAGE_CMD_sdcard) can reuse it
    # record the real p4 (rootfs_data) byte offset chosen by ptgen, so the
    # NuWriter pack step writes ext4 to the exact same place (ptgen adds an
    # alignment gap that a hardcoded offset formula cannot predict).
    echo $((DATA_OFFSET * 512)) > "${KDIR}/${DEVICE_NAME}.rootfs_data_offset"
fi
