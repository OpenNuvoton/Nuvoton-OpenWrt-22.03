do_ma35d0() {
	. /lib/ma35d0.sh

	ma35d0_board_detect
}

boot_hook_add preinit_main do_ma35d0
