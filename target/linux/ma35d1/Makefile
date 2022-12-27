# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=ma35d1
BOARDNAME:=Nuvoton MA35D1
FEATURES:=fpu gpio usb squashfs targz nand ubifs boot-part rootfs-part jffs2
CPU_TYPE:=cortex-a35
SUBTARGETS:=som iot

KERNEL_PATCHVER:=5.10
KERNEL_TESTING_PATCHVER:=5.10

define Target/Description
        Build firmware images for Nuvoton MA35D1 SoC family routers.
endef

include $(INCLUDE_DIR)/target.mk

KERNELNAME:=Image dtbs

DEFAULT_PACKAGES += libopenssl

$(eval $(call BuildTarget))
