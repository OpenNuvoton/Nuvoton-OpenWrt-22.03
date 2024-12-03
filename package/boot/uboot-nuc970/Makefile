#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uboot-nuc970
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/NUC970_U-Boot_v2016.11.git
PKG_SOURCE_DATE:=2024-05-31
PKG_SOURCE_VERSION:=d8e927265bea2dde543806c2f2ac7efedc6def03
PKG_MIRROR_HASH:=cbeaf48c80665c29c8ae4a4f2ba4443a0de7cd3698dc8ab6c6402d0b55a44e75

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=nuc970
  UBOOT_IMAGE:=u-boot.bin
endef

define U-Boot/evb
  NAME:=NUC970 EVB board
  BUILD_SUBTARGET:=evb
  UBOOT_CONFIG:=nuc970
endef

define U-Boot/hmi
  NAME:=N9H30 HMI board
  BUILD_SUBTARGET:=hmi
  UBOOT_CONFIG:=n9h30
endef

UBOOT_TARGETS := \
	evb \
	hmi

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
ifeq ($(BUILD_SUBTARGET), hmi)
	$(foreach img,$(UBOOT_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/$(img) $(BIN_DIR)/openwrt-n9h30-$(BUILD_VARIANT)-$(img); \
	)
else
	$(foreach img,$(UBOOT_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/$(img) $(BIN_DIR)/openwrt-${BOARD}-$(BUILD_VARIANT)-$(img); \
	)
endif
ifeq ($(BUILD_SUBTARGET), hmi)
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin $(BIN_DIR)/openwrt-n9h30-$(BUILD_VARIANT)-u-boot-spl.bin;
else
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin $(BIN_DIR)/openwrt-$(BOARD)-$(BUILD_VARIANT)-u-boot-spl.bin;
endif
endef

$(eval $(call BuildPackage/U-Boot))
