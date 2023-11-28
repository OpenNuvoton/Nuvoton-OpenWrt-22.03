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
	echo DEVICE_NAME=$(DEVICE_NAME) > /tmp/openwrt.env
	$(CP) $(KDIR)/image/${BOARD}-$(SUBTARGET).dtb $(BIN_DIR)/openwrt-$(BOARD)-$(SUBTARGET).dtb
	$(CP) $(TOPDIR)/Nuvoton/uboot_env/$(BOARD)-$(DEVICE_NAME)-u-boot-env.txt $(BIN_DIR)/openwrt-$(BOARD)-$(SUBTARGET)-u-boot-env.txt
endef

define Image/Build
	$(info "Image/Build" $(1))
	$(call Image/Build/$(1),$(1))
ifeq ($(1),squashfs)
	echo ARCH=$(ARCH) >> /tmp/openwrt.env
	echo BOARD=$(BOARD) >> /tmp/openwrt.env
	echo SUBTARGET=$(SUBTARGET) >> /tmp/openwrt.env
	echo PROFILE=$(PROFILE) >> /tmp/openwrt.env
	echo TOPDIR=$(TOPDIR) >> /tmp/openwrt.env
	echo PLATFORM_DIR=$(PLATFORM_DIR) >> /tmp/openwrt.env
	echo KDIR=$(KDIR) >> /tmp/openwrt.env
	echo LINUX_DIR=$(LINUX_DIR) >> /tmp/openwrt.env
	echo BIN_DIR=$(BIN_DIR) >> /tmp/openwrt.env
	echo TOOLCHAIN_DIR=$(TOOLCHAIN_DIR) >> /tmp/openwrt.env
	echo TARGET_CXXFLAGS=\"$(TARGET_CXXFLAGS)\" >> /tmp/openwrt.env
	echo TARGET_CFLAGS=\"$(TARGET_CFLAGS)\" >> /tmp/openwrt.env
	echo TARGET_CPPFLAGS=\"$(TARGET_CPPFLAGS)\" >> /tmp/openwrt.env
	echo GNU_TARGET_NAME=\"$(GNU_TARGET_NAME)\" >> /tmp/openwrt.env
	echo GNU_HOST_NAME=\"$(GNU_HOST_NAME)\" >> /tmp/openwrt.env
	echo STAGING_DIR=$(STAGING_DIR) >> /tmp/openwrt.env
	echo STAGING_DIR_HOST=$(STAGING_DIR_HOST) >> /tmp/openwrt.env
	echo STAGING_DIR_IMAGE=$(STAGING_DIR_IMAGE) >> /tmp/openwrt.env
	echo CONFIG_TARGET_KERNEL_PARTSIZE=$(CONFIG_TARGET_KERNEL_PARTSIZE) >> /tmp/openwrt.env
	echo CONFIG_TARGET_ROOTFS_PARTSIZE=$(CONFIG_TARGET_ROOTFS_PARTSIZE) >> /tmp/openwrt.env
	echo >> /tmp/openwrt.env
	env - BASH_ENV=/tmp/openwrt.env /usr/bin/bash $(TOPDIR)/Nuvoton/script/env-setup.sh
endif
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
  KERNEL_NAME := zImage
  KERNEL_PREFIX := openwrt-$$(BOARD)-$$(SUBTARGET)
  KERNEL := kernel-bin | uImage none
  FILESYSTEMS := squashfs
  IMAGES := firmware.bin sysupgrade.bin
endef

ifeq ($(SUBTARGET),evb)
define Device/nand
  IMAGE_SIZE := 32768k
  PAGESIZE := 2048
  BLOCKSIZE := 128k
  IMAGE/firmware.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | sysupgrade-tar | append-metadata | check-size $$$$(IMAGE_SIZE)
  $(Device/select-dtb)
endef
TARGET_DEVICES += nand

else ifeq ($(SUBTARGET),chili)
define Device/spinor
  IMAGE_SIZE := 32768k
  PAGESIZE := 256
  BLOCKSIZE := 64k
  IMAGE/firmware.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-rootfs | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-rootfs | append-metadata | check-size $$$$(IMAGE_SIZE)
  $(Device/select-dtb)
endef
TARGET_DEVICES += spinor

#else ifneq ($(findstring iot,$(SUBTARGET)),)
else
define Device/spinand
  IMAGE_SIZE := 32768k
  PAGESIZE := 2048
  BLOCKSIZE := 128k
  IMAGE/firmware.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | sysupgrade-tar | append-metadata | check-size $$$$(IMAGE_SIZE)
  $(Device/select-dtb)
endef
TARGET_DEVICES += spinand
endif

$(eval $(call BuildImage))
