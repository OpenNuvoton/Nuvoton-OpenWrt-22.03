do_nuc980() {
	. /lib/nuc980.sh

	nuc980_board_detect
}

# A pre-OTA-DTB ("old") CHILI (SPI-NOR) system flashes a new sysupgrade image
# by writing the whole file raw to the firmware partition, which leaves the
# trailing 'NUCDTBV1' dtb blob sitting at the start of the rootfs_data/overlay
# region. That corrupts the jffs2 overlay so mount_root spews "Magic bitmask
# ... not found" errors on every boot.
#
# Rather than try to salvage the old overlay, just force a one-time full reset:
# when the blob magic is present, "mtd erase" the whole rootfs_data partition
# so mount_root re-initialises a clean jffs2 overlay (equivalent to a factory
# settings reset). This runs at most once -- right after such an upgrade -- and
# normal boots skip it because the magic is gone. Simpler and robust: no need
# to figure out how many blocks the blob touched.
nuc980_clean_ota_dtb_leftover() {
	local board mtd magic

	board=$(nuc980_board_name)
	case "$board" in
	*spinor*) ;;
	*) return 0 ;;
	esac

	mtd=$(grep -m 1 '"rootfs_data"$' /proc/mtd)
	mtd="${mtd%%:*}"
	[ -n "$mtd" ] || return 0

	magic=$(dd if="/dev/$mtd" bs=1 count=8 2>/dev/null)
	[ "$magic" = "NUCDTBV1" ] || return 0

	echo "nuc980: stale OTA dtb blob found on $mtd, resetting overlay"
	mtd erase "/dev/$mtd"
}

boot_hook_add preinit_main do_nuc980
boot_hook_add preinit_main nuc980_clean_ota_dtb_leftover
