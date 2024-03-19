# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=ma35d0
BOARDNAME:=Nuvoton MA35D0
FEATURES:=fpu gpio usb squashfs targz nand ubifs boot-part rootfs-part jffs2
#comment CPU_TYPE due to OpenWrt opkg server not support Cortex-A35 architecture yet
#CPU_TYPE:=cortex-a35
SUBTARGETS:=iot

KERNEL_PATCHVER:=5.10
KERNEL_TESTING_PATCHVER:=5.10

define Target/Description
        Build firmware images for Nuvoton MA35D0 SoC family routers.
endef

include $(INCLUDE_DIR)/target.mk

KERNELNAME:=Image dtbs

DEFAULT_PACKAGES += libopenssl

$(eval $(call BuildTarget))
