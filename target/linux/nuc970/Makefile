# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=nuc970
BOARDNAME:=Nuvoton NUC970/N9H30
FEATURES:=gpio usb squashfs targz nand ubifs boot-part rootfs-part jffs2
CPU_TYPE:=arm926ej-s
SUBTARGETS:=evb hmi

KERNEL_PATCHVER:=5.10

define Target/Description
        Build firmware images for Nuvoton NUC970/N9H30 SoC family routers.
endef

include $(INCLUDE_DIR)/target.mk

KERNELNAME:=zImage dtbs

DEFAULT_PACKAGES += libopenssl

$(eval $(call BuildTarget))
