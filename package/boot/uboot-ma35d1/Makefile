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
PKG_SOURCE_DATE:=2023-10-11
PKG_SOURCE_VERSION:=4cefa19f604b87b1c2ae86313c3dbe817a118018
PKG_MIRROR_HASH:=5396a0ba0ee52cc65d2472c01067e7257497ab5669470e80dea4171efb709433

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define U-Boot/Default
  BUILD_TARGET:=ma35d1
  UBOOT_IMAGE:=u-boot.bin
endef

define U-Boot/generic
  NAME:=MA35D1 board
ifneq ($(findstring spinand,$(PROFILE)),)
  UBOOT_CONFIG:=ma35d1_spinand
else ifneq ($(findstring sdcard0,$(PROFILE)),)
  UBOOT_CONFIG:=ma35d1_sdcard0
else ifneq ($(findstring sdcard1,$(PROFILE)),)
  UBOOT_CONFIG:=ma35d1_sdcard1
else
  UBOOT_CONFIG:=ma35d1_nand
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
