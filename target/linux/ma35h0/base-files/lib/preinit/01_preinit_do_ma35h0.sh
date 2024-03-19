do_ma35h0() {
	. /lib/ma35h0.sh

	ma35h0_board_detect
}

boot_hook_add preinit_main do_ma35h0
