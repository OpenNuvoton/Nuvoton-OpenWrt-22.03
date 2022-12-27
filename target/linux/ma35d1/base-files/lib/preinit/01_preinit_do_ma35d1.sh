do_ma35d1() {
	. /lib/ma35d1.sh

	ma35d1_board_detect
}

boot_hook_add preinit_main do_ma35d1
