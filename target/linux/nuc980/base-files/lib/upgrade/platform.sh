#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/nuc980.sh

PART_NAME="firmware"

platform_check_image() {
	return 0
}

platform_pre_upgrade() {
        local board=$(nuc980_board_name)

        case "$board" in
        *iot*)
                ;;
        esac
}

