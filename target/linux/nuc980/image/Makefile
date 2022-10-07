#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

UBIFS_OPTS = -F -m 2048 -e 124KiB -c 4096 -U
UBI_OPTS = -m 2048 -p 128KiB -s 2048 -O 2048

#################################################
# Images
#################################################

DEVICE_VARS += MKUBIFS_OPTS UBOOT BOOT_SCRIPT

define Build/copy-dtb
	$(CP) $(KDIR)/image/${BOARD}-$(SUBTARGET)*.dtb $(BIN_DIR)/openwrt-$(BOARD)-$(SUBTARGET).dtb
	$(CP) $(KDIR)/../../../Nuvoton/uboot_env/$(BOARD)-$(SUBTARGET)-u-boot-env.txt $(BIN_DIR)/openwrt-$(BOARD)-$(SUBTARGET)-u-boot-env.txt
endef

define Image/Build
	$(info "Image/Build" $(1))
	$(call Image/Build/$(1),$(1))
endef


#################################################
# Devices
#################################################

KERNEL_LOADADDR=0x00008000

define Device/select-dtb
  IMAGES += image-dtb
  IMAGE/image-dtb := copy-dtb
endef

define Device/Default
  PROFILES := Default
  KERNEL_INSTALL := 1
  KERNEL_SUFFIX := -uImage
  KERNEL_NAME := Image
  KERNEL_PREFIX := openwrt-$$(BOARD)-$$(SUBTARGET)
  KERNEL := kernel-bin | uImage none
  FILESYSTEMS := squashfs
  IMAGES := firmware.bin sysupgrade.bin
endef

ifeq ($(SUBTARGET),chili)
define Device/chili
  IMAGE_SIZE := 32768k
  PAGESIZE := 256
  BLOCKSIZE := 64k
  IMAGE/firmware.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-rootfs | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-rootfs | append-metadata | check-size $$$$(IMAGE_SIZE)
  $(Device/select-dtb)
endef
TARGET_DEVICES += chili
endif

ifeq ($(SUBTARGET),iot)
define Device/iot
  IMAGE_SIZE := 32768k
  PAGESIZE := 2048
  BLOCKSIZE := 128k
  IMAGE/firmware.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
  $(Device/select-dtb)
endef
TARGET_DEVICES += iot
endif

$(eval $(call BuildImage))
