#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/nuc980.sh

PART_NAME="firmware"

platform_check_image() {
	return 0
}

# NUC980 stores the kernel device tree in its own "dtb" flash partition (see
# the partition layout in nuc980-<board>.dts). u-boot loads it from the raw
# offset that partition starts at (the "loaddtb" command in
# Nuvoton/uboot_env/nuc980-*-u-boot-env.txt), so OTA just rewrites the whole
# "dtb" partition -- mirroring the MA35 "device-tree" partition update, and
# leaving the uboot and firmware partitions untouched.
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

# CHILI (SPI-NOR) writes a RAW NOR firmware image (byte 0 = kernel uImage) to
# the firmware partition. The build appends a trailing, 64 KiB-aligned blob:
#   'NUCDTBV1' <8 hex firmware length> <8 hex dtb length> <dtb>
# On the new system we locate the blob (only dd/wc are used, no grep -b),
# refresh the separate "dtb" partition from it, and then flash ONLY the
# firmware (kernel+rootfs, the recorded length) so the dtb blob never reaches
# the rootfs_data/overlay region -- the overlay and saved config stay clean and
# the dtb change takes effect on the next reboot, matching the spinand/nand
# boards. Any problem is non-fatal: we fall back to a plain full flash so the
# board always stays bootable. (A pre-OTA-DTB "old" system that writes the
# whole file raw leaves the blob in rootfs_data; the nuc980 preinit hook wipes
# it on the next boot.)
platform_do_upgrade_spinor() {
	local tar_file="$1"
	local size off found fwhex dtbhex fwlen dtblen mtd fwblocks fwrem bs=65536

	size=$(wc -c < "$tar_file")
	off=0
	found=""
	while [ "$off" -lt "$size" ]; do
		if [ "$(dd if="$tar_file" bs=1 skip="$off" count=8 2>/dev/null)" = "NUCDTBV1" ]; then
			found="$off"
			break
		fi
		off=$((off + bs))
	done

	# No blob (stock/old image): flash as-is and leave the dtb partition alone.
	[ -n "$found" ] || {
		default_do_upgrade "$tar_file"
		return
	}

	fwhex=$(dd if="$tar_file" bs=1 skip=$((found + 8)) count=8 2>/dev/null)
	dtbhex=$(dd if="$tar_file" bs=1 skip=$((found + 16)) count=8 2>/dev/null)
	fwlen=0
	dtblen=0
	case "$fwhex" in
	[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
		fwlen=$(( 0x$fwhex )) ;;
	esac
	case "$dtbhex" in
	[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
		dtblen=$(( 0x$dtbhex )) ;;
	esac

	# Refresh the separate "dtb" partition from the incoming blob.
	mtd=$(grep -m 1 '"dtb"$' /proc/mtd)
	mtd="${mtd%%:*}"
	if [ -n "$mtd" ] && [ "$dtblen" -gt 0 ]; then
		dd if="$tar_file" bs=1 skip=$((found + 24)) count="$dtblen" \
			of=/tmp/dtb.bin 2>/dev/null

		# Only write a real device tree (FDT magic d0 0d fe ed) so a truncated
		# or corrupt blob can never brick the "dtb" partition. The sysupgrade
		# ramdisk busybox may lack "cmp"/"head", so compare the 4 magic bytes
		# with plain shell string equality (only dd + printf are needed).
		if [ "$(dd if=/tmp/dtb.bin bs=1 count=4 2>/dev/null)" = "$(printf '\xd0\x0d\xfe\xed')" ]; then
			echo "Updating device-tree partition (/dev/$mtd)..."
			mtd write /tmp/dtb.bin "/dev/$mtd"
		fi
		rm -f /tmp/dtb.bin
	fi

	# Flash ONLY the firmware (kernel+rootfs); dropping the trailing blob keeps
	# it out of the rootfs_data/overlay region, so the overlay stays clean and
	# the saved config is preserved exactly like default_do_upgrade. Feed exactly
	# fwlen bytes with dd (not "head", which the sysupgrade ramdisk busybox may
	# not provide): whole 64 KiB blocks plus any tail remainder.
	echo "Writing firmware to ${PART_NAME:-firmware}..."
	if [ "$fwlen" -gt 0 ]; then
		fwblocks=$((fwlen / bs))
		fwrem=$((fwlen % bs))
		if [ -n "$UPGRADE_BACKUP" ]; then
			{
				[ "$fwblocks" -gt 0 ] && dd if="$tar_file" bs="$bs" count="$fwblocks" 2>/dev/null
				[ "$fwrem" -gt 0 ] && dd if="$tar_file" bs=1 skip=$((fwblocks * bs)) count="$fwrem" 2>/dev/null
			} | mtd -j "$UPGRADE_BACKUP" write - "${PART_NAME:-firmware}"
		else
			{
				[ "$fwblocks" -gt 0 ] && dd if="$tar_file" bs="$bs" count="$fwblocks" 2>/dev/null
				[ "$fwrem" -gt 0 ] && dd if="$tar_file" bs=1 skip=$((fwblocks * bs)) count="$fwrem" 2>/dev/null
			} | mtd write - "${PART_NAME:-firmware}"
		fi
	else
		default_do_upgrade "$tar_file"
	fi
}

platform_do_upgrade() {
        local board=$(nuc980_board_name)

        case "$board" in
        *spinor*)
		REQUIRE_IMAGE_METADATA=1
		platform_do_upgrade_spinor "$1"
		;;
        *spinand*)
		platform_do_upgrade_dtb "$1"
		REQUIRE_IMAGE_METADATA=1
		nand_do_upgrade "$1"
		;;
        *nand*)
		platform_do_upgrade_dtb "$1"
		REQUIRE_IMAGE_METADATA=1
		nand_do_upgrade "$1"
		;;
        esac
}

