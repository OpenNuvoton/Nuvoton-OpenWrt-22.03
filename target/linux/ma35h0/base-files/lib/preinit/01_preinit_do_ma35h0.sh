do_ma35h0() {
	. /lib/ma35h0.sh

	ma35h0_board_detect
}

# On NAND/SPINAND the overlay is a UBIFS volume that fstools mounts directly
# (mount_root -> mount_overlay). /sbin/block (block-mount) is only needed for
# the SD-card ext4 "rootfs_data" extroot, but it is now shipped in the shared
# squashfs because of the SD-card overlay feature. On every boot mount_root
# calls mount_extroot(), which - the moment it finds a regular /sbin/block -
# runs "block extroot"; that mounts the data volume to hunt for extroot config,
# producing the extra "block:" messages and the ubifs mount/unmount/remount
# cycle even on NAND where there is no ext4 rootfs_data at all.
#
# mount_extroot() bails out early (return -1) if /sbin/block is not a regular
# file, so on NAND/SPINAND we shadow it with /dev/null before mount_root runs.
# This makes NAND boot as clean as an image without block-mount. The bind mount
# lives only in the pre-pivot namespace; once mount_root pivots the UBIFS
# overlay, /sbin/block resolves to the real binary from the squashfs lower
# again, so runtime block/hotplug and SD-card extroot are unaffected.
ma35h0_skip_extroot() {
	case "$(cat /proc/cmdline)" in
	*boot=nand*|*boot=spinand*) ;;
	*) return 0 ;;
	esac

	[ -e /sbin/block ] || return 0

	mount -o bind /dev/null /sbin/block
}

# The /dev/null shadow above only lives in the pre-pivot namespace; mount_root's
# switch to the UBIFS overlay moves it aside (to /rom/sbin/block) and the real
# /sbin/block from the squashfs is visible again, so procd/hotplug run it during
# init. On 22.03 that block enumerates and opens every UBI volume node to probe
# its filesystem, including the already-mounted "rootfs_data" volume, whose
# char device is held by UBIFS - so the open returns EBUSY and block spams
# "ubi_open_volume ... error -16" endlessly (24.10's newer block skips mounted
# volumes). We must keep block running so USB mass storage still auto-mounts,
# so instead of disabling block we hide just the busy volume: once the overlay
# is up (preinit_mount_root, post-pivot) bind /dev/null over the rootfs_data UBI
# volume node. block's blkid probe then opens an empty /dev/null and skips it,
# while every real block device (USB, SD) is still enumerated and auto-mounted.
# UBIFS keeps the volume mounted through the kernel, unaffected by the node bind.
ma35h0_hide_rootfs_data() {
	case "$(cat /proc/cmdline)" in
	*boot=nand*|*boot=spinand*) ;;
	*) return 0 ;;
	esac

	local name node
	for name in /sys/class/ubi/ubi0_*/name; do
		[ -f "$name" ] || continue
		[ "$(cat "$name" 2>/dev/null)" = "rootfs_data" ] || continue

		node="/dev/$(basename "$(dirname "$name")")"
		[ -e "$node" ] || continue

		mount -o bind /dev/null "$node"
	done
}

boot_hook_add preinit_main do_ma35h0
boot_hook_add preinit_main ma35h0_skip_extroot
boot_hook_add preinit_mount_root ma35h0_hide_rootfs_data
