do_ma35d05k() {
	. /lib/ma35d05k.sh

	ma35d05k_board_detect
}

boot_hook_add preinit_main do_ma35d05k
