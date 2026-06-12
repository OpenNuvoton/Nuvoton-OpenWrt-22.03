#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

MA35D05K_BOARD_NAME=
MA35D05K_MODEL=

ma35d05k_board_detect() {
	local machine
	local memory
	local storage

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"Nuvoton MA35D05K-IoT")
		if grep "mem=2" /proc/cmdline
		then
			memory="256m"
		elif grep "mem=5" /proc/cmdline
		then
			memory="512m"
		else
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

	[ -z "$MA35D05K_BOARD_NAME" ] && MA35D05K_BOARD_NAME="$memory"-"$storage"
	[ -z "$MA35D05K_MODEL" ] && MA35D05K_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$MA35D05K_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$MA35D05K_MODEL" > /tmp/sysinfo/model
}

ma35d05k_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -n "$name" ] || name="unknown"

	echo "$name"
}

