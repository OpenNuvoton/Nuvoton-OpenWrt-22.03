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
PKG_SOURCE_DATE:=2024-09-19
PKG_SOURCE_VERSION:=266e07c60a6e52b31f0db4765e5c761983ecdd4b
PKG_MIRROR_HASH:=c9040a74297d8592f18c21e25dc21378ae071fa7a7abb2d51b5bccc5ee0a4c89

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define U-Boot/Default
  BUILD_TARGET:=$(BOARD)
  UBOOT_IMAGE:=u-boot.bin
  DEPENDS:=@(TARGET_ma35d1||TARGET_ma35d0||TARGET_ma35h0)
endef

define U-Boot/generic
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

UBOOT_TARGETS:=generic

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
