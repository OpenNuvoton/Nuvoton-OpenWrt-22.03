#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uboot-ma35d1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/MA35D1_u-boot-v2020.07.git
PKG_SOURCE_DATE:=2026-05-15
PKG_SOURCE_VERSION:=27273d62c8ba363eddb0dc590e9f30d692cc1243
PKG_MIRROR_HASH:=f78c4aa91870af7f1bd5ba94d5660e2ff7822e478ad78975f232073acdea379e

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define U-Boot/Default
  BUILD_TARGET:=$(BOARD)
  UBOOT_IMAGE:=u-boot.bin
  DEPENDS:=@(TARGET_ma35d1||TARGET_ma35d0||TARGET_ma35d05k||TARGET_ma35h0)
endef

define U-Boot/ma35d1
  NAME:=MA35 board
ifneq ($(findstring spinand,$(PROFILE)),)
  UBOOT_CONFIG:=$(BOARD)_spinand
else ifneq ($(findstring sdcard0,$(PROFILE)),)
  UBOOT_CONFIG:=$(BOARD)_sdcard0
else ifneq ($(findstring sdcard1,$(PROFILE)),)
  UBOOT_CONFIG:=$(BOARD)_sdcard1
else
  UBOOT_CONFIG:=$(BOARD)_nand
endif
endef

UBOOT_TARGETS:=ma35d1

$(info PROFILE = $(PROFILE))

define Build/InstallDev
	touch /tmp/openwrt.boot
	sed -i /^UBOOT_/d /tmp/openwrt.boot
	echo UBOOT_CONFIG=$(UBOOT_CONFIG) >> /tmp/openwrt.boot
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(foreach img,$(UBOOT_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/$(img) $(STAGING_DIR_IMAGE)/$(img); \
	)
endef

$(eval $(call BuildPackage/U-Boot))
