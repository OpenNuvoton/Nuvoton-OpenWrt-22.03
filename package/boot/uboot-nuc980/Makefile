#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=2016.11
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/NUC970_U-Boot_v2016.11.git
PKG_SOURCE_DATE:=2022-08-26
PKG_SOURCE_VERSION:=2f0c3aaff9b7b0279420736b93990211f4504e44

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=nuc980
  UBOOT_IMAGE:=u-boot.bin
endef

define U-Boot/chili
  NAME:=NUC980 Chili board
  BUILD_SUBTARGET:=chili
  UBOOT_CONFIG:=nuc980_chili
endef

define U-Boot/iot
  NAME:=NUC980 IoT board
  BUILD_SUBTARGET:=iot
  UBOOT_CONFIG:=nuc980_iot
endef

UBOOT_TARGETS := \
	chili \
	iot

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(foreach img,$(UBOOT_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/$(img) $(BIN_DIR)/openwrt-${BOARD}-$(BUILD_VARIANT)-$(img); \
	)
#ifneq (,$(wildcard $(PKG_BUILD_DIR)/spl/u-boot-spl.bin))
ifneq ($(1), chili)
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin $(BIN_DIR)/openwrt-$(BOARD)-$(BUILD_VARIANT)-u-boot-spl.bin
endif
endef

$(eval $(call BuildPackage/U-Boot))
