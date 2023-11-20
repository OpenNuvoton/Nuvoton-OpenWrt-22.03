#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/nuc970.sh

PART_NAME="firmware"

platform_check_image() {
	return 0
}

platform_do_upgrade() {
        local board=$(nuc970_board_name)

        case "$board" in
        *nand*)
		REQUIRE_IMAGE_METADATA=1
		nand_do_upgrade "$1"
		;;
        *spinor*)
		REQUIRE_IMAGE_METADATA=1
		default_do_upgrade "$1"
		;;
        esac
}

