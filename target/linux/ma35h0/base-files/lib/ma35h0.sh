#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

MA35H0_BOARD_NAME=
MA35H0_MODEL=

ma35h0_board_detect() {
	local machine
	local memory
	local storage

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"Nuvoton MA35H0-HMI")
		if grep "mem=1" /proc/cmdline
		then
			memory="128m"
		fi
		;;
	*)
		memory="generic"
		;;
	esac

	if grep "boot=mmc" /proc/cmdline
	then
		storage="sdcard"
	elif grep "boot=spinand" /proc/cmdline
	then
		storage="spinand"
	elif grep "boot=nand" /proc/cmdline
	then
		storage="nand"
	fi

	[ -z "$MA35H0_BOARD_NAME" ] && MA35H0_BOARD_NAME="$memory"-"$storage"
	[ -z "$MA35H0_MODEL" ] && MA35H0_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$MA35H0_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$MA35H0_MODEL" > /tmp/sysinfo/model
}

ma35h0_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -n "$name" ] || name="unknown"

	echo "$name"
}

