#!/bin/sh
#
# Copyright (C) 2014 OpenWrt.org
#

MA35D1_BOARD_NAME=
MA35D1_MODEL=

ma35d1_board_detect() {
	local machine
	local memory
	local storage

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"Nuvoton MA35D1-SOM")
		if grep "mem=2" /proc/cmdline
		then
			memory="256m"
		elif grep "mem=5" /proc/cmdline
		then
			memory="512m"
		else
			memory="1g"
		fi
		;;
	"Nuvoton MA35D1-IoT")
		if grep "mem=1" /proc/cmdline
		then
			memory="128m"
		else
			memory="512m"
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

	[ -z "$MA35D1_BOARD_NAME" ] && MA35D1_BOARD_NAME="$memory"-"$storage"
	[ -z "$MA35D1_MODEL" ] && MA35D1_MODEL="$machine"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$MA35D1_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$MA35D1_MODEL" > /tmp/sysinfo/model
}

ma35d1_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -n "$name" ] || name="unknown"

	echo "$name"
}

