#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

NUC970_BOARD_NAME=
NUC970_MODEL=

nuc970_board_detect() {
	local machine
	local name

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"Nuvoton NUC972 EVB")
		name="nand"
		;;
	"numaker-hmi-n9h30")
		name="nand"
		;;
	*)
		name="generic"
		;;
	esac

	[ -z "$NUC970_BOARD_NAME" ] && NUC970_BOARD_NAME="$name"
	[ -z "$NUC970_MODEL" ] && NUC970_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$NUC970_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$NUC970_MODEL" > /tmp/sysinfo/model
}

nuc970_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -n "$name" ] || name="unknown"

	echo "$name"
}

