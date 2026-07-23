#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/ma35d1.sh


platform_check_image() {
	return 0
}

platform_do_upgrade_dtb() {
	local tar_file="$1"
	local board_dir

	# Locate the sysupgrade-<board> directory inside the tarball
	board_dir=$(tar tf "$tar_file" 2>/dev/null | grep -m 1 '^sysupgrade-.*/$')
	board_dir="${board_dir%/}"
	[ -n "$board_dir" ] || return 0

	# Skip silently if this image does not carry a device tree
	tar tf "$tar_file" "${board_dir}/dtb" >/dev/null 2>&1 || return 0

	# Two partitions are named "device-tree" because both the raw NAND and
	# the SPI-NAND controllers are enabled. Relying on /proc/mtd order alone
	# is fragile (it depends on probe order), so bind the choice to the flash
	# we actually booted from: u-boot passes boot=nand / boot=spinand on the
	# kernel command line, and each mtd's parent controller in sysfs tells us
	# which flash it belongs to (SPI-NAND sits on an SPI bus). Only shell
	# builtins are used -- head/tail/cut/readlink are not in the ramdisk.
	local want_spi=0 dtb_mtd="" d name path
	grep -q "boot=spinand" /proc/cmdline && want_spi=1

	for d in /sys/class/mtd/mtd*; do
		case "$d" in *ro) continue ;; esac	# skip mtdNro read-only aliases
		[ -r "$d/name" ] || continue
		read -r name < "$d/name"
		[ "$name" = "device-tree" ] || continue

		# Resolve the parent controller path (cd+pwd avoids readlink)
		path=$(cd "$d/device" 2>/dev/null && pwd -P)
		case "$path" in
		*spi*) [ "$want_spi" = 1 ] && dtb_mtd=${d##*/} ;;
		*)     [ "$want_spi" = 0 ] && dtb_mtd=${d##*/} ;;
		esac
	done

	# Fallback if sysfs could not disambiguate: use /proc/mtd order
	# (NAND probes first, SPI-NAND last).
	if [ -z "$dtb_mtd" ]; then
		local line mtd
		while IFS= read -r line; do
			case "$line" in
			*'"device-tree"'*)
				mtd="${line%%:*}"
				dtb_mtd="$mtd"
				[ "$want_spi" = 1 ] || break
				;;
			esac
		done < /proc/mtd
	fi

	[ -n "$dtb_mtd" ] || {
		echo "device-tree partition not found, skipping DTB update."
		return 0
	}

	echo "Updating device-tree partition (/dev/$dtb_mtd)..."
	tar xf "$tar_file" "${board_dir}/dtb" -O > /tmp/dtb.bin
	mtd write /tmp/dtb.bin "/dev/$dtb_mtd"
	rm -f /tmp/dtb.bin
}

platform_do_upgrade_sdcard() {
	local diskdev partdev diff

	export_bootdevice && export_partdevice diskdev 0 || {
		echo "Unable to determine upgrade device"
		return 1
	}

	sync

	# Always read the incoming image's partition table: the offsets are needed
	# both to detect a layout change and to place kernel/rootfs/rootfs_data
	# when the layout did change.
	#read the first 256 KiB (partition table area) from the image
	get_image "$@" | dd of=/tmp/image.bs count=1 bs=512b
	get_partitions /tmp/image.bs image

	if [ "$UPGRADE_OPT_SAVE_PARTITIONS" = "1" ]; then
		get_partitions "/dev/$diskdev" bootdisk

		# Compare the tables in BOTH directions. The image may ADD partitions
		# (ext4-only -> overlay) or DROP them (overlay -> ext4-only). A one-way
		# "image not in bootdisk" diff only catches the grow case; the shrink
		# case leaves a stale p4 (rootfs_data) in the on-disk table, which fstab
		# then wrongly mounts as an overlay on top of the ext4-only root. Any
		# difference forces the loader-preserving reinstall below, which
		# rewrites the MBR to exactly match the new image (dropping p4).
		diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image; grep -F -x -v -f /tmp/partmap.image /tmp/partmap.bootdisk)"
	else
		diff=1
	fi

	if [ -n "$diff" ]; then
		# The partition layout changed (e.g. ext4-only <-> overlay) or a full
		# reinstall was requested. Reinstall the partition table, device tree
		# and every partition at the offsets defined by the NEW image, but
		# NEVER touch the raw loader region (sectors 1..5631: BL2 header, BL2,
		# u-boot env, FIP). The sysupgrade image does not carry those loaders
		# (they only live in the NuWriter pack), so the previous whole-disk
		# "dd from sector 0" zeroed them out and left the board unbootable
		# ("No image in SD"). Writing by absolute LBA also drops the dependency
		# on partx, which is not shipped in the image; the kernel re-reads the
		# new table on the following reboot.
		echo "Partition layout changed, reinstalling (loaders preserved)..."

		# New partition table (MBR, sector 0 only -- keep sectors 1..5631).
		dd if=/tmp/image.bs of="/dev/$diskdev" bs=512 count=1 conv=fsync

		# Device tree (raw, sector 5632 = 0x2c0000).
		get_image "$@" | dd of="/dev/$diskdev" ibs=512 obs=512 skip=5632 seek=5632 count=512 conv=fsync

		# Kernel (p2), rootfs (p3) and, for the overlay layout, rootfs_data
		# (p4). Written by absolute LBA to the whole-disk device because the
		# kernel still sees the old table, so the new partition nodes may not
		# exist yet. Skip p1 (loader partition) to preserve the loaders.
		while read part start size; do
			[ "$part" = "1" ] && continue
			echo "Writing partition $part ($start +$size sectors)..."
			get_image "$@" | dd of="/dev/$diskdev" ibs=512 obs=512 skip="$start" seek="$start" count="$size" conv=fsync
		done < /tmp/partmap.image

		return 0
	fi

	#skip first partition
	# 1: redundant for loaders
	# 2: kernel
	# 3: rootfs
	sed -i '1d' /tmp/partmap.image

	# The device tree lives in the raw gap between the loader and kernel
	# partitions (sector 5632 = 0x2c0000, 256 KiB) and is read by u-boot via
	# "mmc read fdt 0x1600 0x80". It is not covered by any partition device,
	# so the per-partition writes below would skip it. Copy it straight from
	# the image to keep DTB+kernel+rootfs in sync, matching NAND/SPI-NAND OTA.
	echo "Writing device-tree to /dev/$diskdev..."
	get_image "$@" | dd of="/dev/$diskdev" ibs=512 obs=512 skip=5632 seek=5632 count=512 conv=fsync

	#(disabled) write u-boot image
	#get_image "$@" | dd of="$diskdev" bs=1024 skip=8 seek=8 count=1016 conv=fsync
	# Reflash only kernel (p2) and rootfs (p3). In the overlay layout the p4
	# "rootfs_data" ext4 partition holds the user settings and is left
	# untouched so OTA preserves them (mirroring squashfs+ubifs NAND). In the
	# ext4-only layout there is no p4; the settings live in p3 itself and are
	# restored afterwards by platform_copy_config from the sysupgrade backup.
	while read part start size; do
		case "$part" in
			2) imgname="kernel" ;;
			3) imgname="rootfs" ;;
			*)
				echo "Preserving partition $part (rootfs_data / overlay)."
				continue
				;;
		esac
		if export_partdevice partdev $part; then
			echo "Writing $imgname to /dev/$partdev..."
			get_image "$@" | dd of="/dev/$partdev" ibs="512" obs=1M skip="$start" count="$size" conv=fsync
		else
			echo "Unable to find partition $part device, skipped."
		fi
	done < /tmp/partmap.image

	#(disabled) copy partition uuid
	#echo "Writing new UUID to /dev/$diskdev..."
	#get_image "$@" | dd of="/dev/$diskdev" bs=1 skip=440 count=4 seek=440 conv=fsync
}

# Restore the saved configuration after an sdcard sysupgrade. do_upgrade()
# calls this once platform_do_upgrade has run (when config is being kept).
#
# The two build-time layouts (selected by CONFIG_TARGET_SDCARD_DATA_PARTSIZE)
# keep their settings in different places, so restoration differs:
#   overlay (p4 present) : platform_do_upgrade_sdcard preserved the ext4
#                          "rootfs_data" overlay (p4) untouched, so the settings
#                          it holds are already intact -- nothing to do.
#   ext4-only (no p4)    : the writable root (p3) was just reflashed, wiping the
#                          settings stored in it, so extract the backup archive
#                          back onto the fresh root.
platform_copy_config() {
	local partdev

	case "$(ma35d1_board_name)" in
		*sdcard*) ;;
		*) return 0 ;;
	esac

	[ -n "$UPGRADE_BACKUP" ] && [ -f "$UPGRADE_BACKUP" ] || return 0

	export_bootdevice || return 0

	# Overlay layout: rootfs_data (p4) was preserved, settings already intact.
	export_partdevice partdev 4 && return 0

	# ext4-only layout: restore the config backup onto the reflashed root (p3).
	export_partdevice partdev 3 || return 0

	mkdir -p /tmp/new_root
	if mount -t ext4 -o rw,noatime "/dev/$partdev" /tmp/new_root; then
		echo "Restoring configuration to /dev/$partdev (ext4-only root)..."
		tar -C /tmp/new_root -xzf "$UPGRADE_BACKUP"
		sync
		umount /tmp/new_root
	else
		echo "Unable to mount /dev/$partdev, configuration not restored."
	fi
	rmdir /tmp/new_root 2>/dev/null
}

platform_do_upgrade() {
	local board=$(ma35d1_board_name)

	case "$board" in
	*nand*)
		platform_do_upgrade_dtb "$1"
		PART_NAME="firmware"
		REQUIRE_IMAGE_METADATA=1
		#default_do_upgrade "$1"
		nand_do_upgrade "$1"
		;;
	*sdcard*)
		platform_do_upgrade_sdcard "$1"
		return 0
		;;
	*)
		echo "Sysupgrade is not currently supported on $board"
		;;
	esac
}

