#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/nuc980.sh

PART_NAME="firmware"

platform_check_image() {
	return 0
}

platform_do_upgrade() {
        local board=$(nuc980_board_name)

        case "$board" in
        *spinor*)
		REQUIRE_IMAGE_METADATA=1
		default_do_upgrade "$1"
		;;
        *spinand*)
		REQUIRE_IMAGE_METADATA=1
		nand_do_upgrade "$1"
		;;
        esac
}

