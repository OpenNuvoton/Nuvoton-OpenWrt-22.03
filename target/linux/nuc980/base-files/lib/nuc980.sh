#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

NUC980_BOARD_NAME=
NUC980_MODEL=

nuc980_board_detect() {
	local machine
	local name

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"Nuvoton NUC980 CHILI V1.0")
		name="spinor"
		;;
	"Nuvoton NUC980 IOT V1.0")
		name="spinand"
		;;
	"Nuvoton NUC980 Server V1.0")
		name="spinand"
		;;
	*)
		name="generic"
		;;
	esac

	[ -z "$NUC980_BOARD_NAME" ] && NUC980_BOARD_NAME="$name"
	[ -z "$NUC980_MODEL" ] && NUC980_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$NUC980_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$NUC980_MODEL" > /tmp/sysinfo/model
}

nuc980_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -n "$name" ] || name="unknown"

	echo "$name"
}

