#!/bin/sh

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
	TSLIB_TSDEVICE=/dev/input/event0
elif [ -e /dev/input/event1 ]; then
	TSLIB_TSDEVICE=/dev/input/event1
else
	TSLIB_TSDEVICE=/dev/input/event0
fi
TSLIB_CONFFILE=/etc/ts.conf
TSLIB_CALIBFILE=/etc/pointercal
LD_LIBRARY_PATH=/lib/ts/

export TSLIB_TSDEVICE
export TSLIB_CONFFILE
export TSLIB_CALIBFILE
export LD_LIBRARY_PATH
