do_nuc970() {
	. /lib/nuc970.sh

	nuc970_board_detect
}

boot_hook_add preinit_main do_nuc970
