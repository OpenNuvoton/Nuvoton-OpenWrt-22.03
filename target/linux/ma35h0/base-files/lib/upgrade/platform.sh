#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/ma35h0.sh


platform_check_image() {
	return 0
}

platform_do_upgrade_sdcard() {
	local diskdev partdev diff

	export_bootdevice && export_partdevice diskdev 0 || {
		echo "Unable to determine upgrade device"
		return 1
	}

	sync

	if [ "$UPGRADE_OPT_SAVE_PARTITIONS" = "1" ]; then
		get_partitions "/dev/$diskdev" bootdisk

		#extract the boot sector from the image
		get_image "$@" | dd of=/tmp/image.bs count=1 bs=512b

		get_partitions /tmp/image.bs image

		#compare tables
		diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"
	else
		diff=1
	fi

	if [ -n "$diff" ]; then
		get_image "$@" | dd of="/dev/$diskdev" bs=4096 conv=fsync

		# Separate removal and addtion is necessary; otherwise, partition 1
		# will be missing if it overlaps with the old partition 2
		partx -d - "/dev/$diskdev"
		partx -a - "/dev/$diskdev"

		return 0
	fi

	#skip first partition
	# 1: redundant for loaders
	# 2: kernel
	# 3: rootfs
	sed -i '1d' /tmp/partmap.image

	#write uboot image
	#get_image "$@" | dd of="$diskdev" bs=1024 skip=8 seek=8 count=1016 conv=fsync
	#iterate over each partition from the image and write it to the boot disk
	while read part start size; do
		if export_partdevice partdev $part; then
			echo "Writing image to /dev/$partdev..."
			get_image "$@" | dd of="/dev/$partdev" ibs="512" obs=1M skip="$start" count="$size" conv=fsync
		else
			echo "Unable to find partition $part device, skipped."
		fi
	done < /tmp/partmap.image

	#copy partition uuid
	#echo "Writing new UUID to /dev/$diskdev..."
	#get_image "$@" | dd of="/dev/$diskdev" bs=1 skip=440 count=4 seek=440 conv=fsync
}

platform_do_upgrade() {
	local board=$(ma35h0_board_name)

	case "$board" in
	*nand*)
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

