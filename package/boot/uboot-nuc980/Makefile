#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uboot-nuc980
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/NUC970_U-Boot_v2016.11.git
PKG_SOURCE_DATE:=2022-08-26
PKG_SOURCE_VERSION:=2f0c3aaff9b7b0279420736b93990211f4504e44
PKG_MIRROR_HASH:=f3f5fe7772ed4c79253bf385df3aeb7d61605ec54b632031417a8a23cab95d32

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=nuc980
  UBOOT_IMAGE:=u-boot.bin
endef

define U-Boot/evb
  NAME:=NUC980 EVB board
  BUILD_SUBTARGET:=evb
  UBOOT_CONFIG:=nuc980
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

define U-Boot/iotg2
  NAME:=NUC980 IoT-G2 board
  BUILD_SUBTARGET:=iotg2
  UBOOT_CONFIG:=nuc980_iot
endef

define U-Boot/server
  NAME:=NUC980 Server board
  BUILD_SUBTARGET:=server
  UBOOT_CONFIG:=nuc980_eth2uart
endef

UBOOT_TARGETS := \
	evb \
	chili \
	iot \
	iotg2 \
	server

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(foreach img,$(UBOOT_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/$(img) $(BIN_DIR)/openwrt-${BOARD}-$(BUILD_VARIANT)-$(img); \
	)
#ifneq (,$(wildcard $(PKG_BUILD_DIR)/spl/u-boot-spl.bin))
ifneq ($(BUILD_SUBTARGET), chili)
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin $(BIN_DIR)/openwrt-$(BOARD)-$(BUILD_VARIANT)-u-boot-spl.bin
endif
endef

$(eval $(call BuildPackage/U-Boot))
