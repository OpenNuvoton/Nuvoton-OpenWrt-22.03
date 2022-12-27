#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

PKG_NAME:=uboot-ma35d1
PKG_VERSION:=2020.07
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/MA35D1_u-boot-v2020.07.git
PKG_SOURCE_DATE:=2022-12-06
PKG_SOURCE_VERSION:=4b6aaab6d7fc0807c943a57e093ca1304a7f0254

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=ma35d1
  UBOOT_IMAGE:=u-boot.bin
endef

define U-Boot/generic
  NAME:=MA35D1 board
ifneq ($(findstring spinand,$(PROFILE)),)
  UBOOT_CONFIG:=ma35d1_spinand
else ifneq ($(findstring sdcard,$(PROFILE)),)
ifeq ($(SUBTARGET),iot)
  UBOOT_CONFIG:=ma35d1_sdcard1
else ifeq ($(SUBTARGET),som)
  UBOOT_CONFIG:=ma35d1_sdcard0
endif
else
  UBOOT_CONFIG:=ma35d1_nand
endif
endef

UBOOT_TARGETS:=generic

$(info PROFILE = $(PROFILE))

define Build/InstallDev
	echo UBOOT_CONFIG=$(UBOOT_CONFIG) >> /tmp/openwrt.env
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(foreach img,$(UBOOT_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/$(img) $(STAGING_DIR_IMAGE)/$(img); \
	)
	$(STAGING_DIR_IMAGE)/fiptool create \
		--soc-fw $(STAGING_DIR_IMAGE)/bl31.bin \
		--tos-fw $(STAGING_DIR_IMAGE)/tee-header_v2.bin \
		--tos-fw-extra1 $(STAGING_DIR_IMAGE)/tee-pager_v2.bin \
		--nt-fw $(STAGING_DIR_IMAGE)/u-boot.bin \
		$(STAGING_DIR_IMAGE)/fip.bin
endef

$(eval $(call BuildPackage/U-Boot))
