#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/nuc970.sh

PART_NAME="firmware"

platform_check_image() {
	return 0
}

# NUC970/N9H30 stores the kernel device tree in its own "dtb" flash partition
# (see the uboot/dtb/firmware layout in nuc970-evb.dts and n9h30-hmi.dts). u-boot
# loads it from the raw offset that partition starts at, so OTA just rewrites the
# whole "dtb" partition -- mirroring the MA35/NUC980 "dtb" partition update, and
# leaving the uboot and firmware partitions untouched. Both NUC970 boards are
# NAND, so this is the only extra step needed (no SPI-NOR handling).
platform_do_upgrade_dtb() {
	local tar_file="$1"
	local board_dir mtd

	# Locate the sysupgrade-<board> directory inside the tarball.
	board_dir=$(tar tf "$tar_file" 2>/dev/null | grep -m 1 '^sysupgrade-.*/$')
	board_dir="${board_dir%/}"
	[ -n "$board_dir" ] || return 0

	# Skip silently if this image does not carry a device tree.
	tar tf "$tar_file" "${board_dir}/dtb" >/dev/null 2>&1 || return 0

	# Dedicated "dtb" partition (uboot / dtb / firmware layout).
	mtd=$(grep -m 1 '"dtb"$' /proc/mtd)
	mtd="${mtd%%:*}"
	[ -n "$mtd" ] || {
		echo "device-tree partition not found, skipping DTB update."
		return 0
	}

	echo "Updating device-tree partition (/dev/$mtd)..."
	tar xf "$tar_file" "${board_dir}/dtb" -O > /tmp/dtb.bin
	mtd write /tmp/dtb.bin "/dev/$mtd"
	rm -f /tmp/dtb.bin
}

platform_do_upgrade() {
        local board=$(nuc970_board_name)

        case "$board" in
        *nand*)
		platform_do_upgrade_dtb "$1"
		REQUIRE_IMAGE_METADATA=1
		nand_do_upgrade "$1"
		;;
        esac
}

