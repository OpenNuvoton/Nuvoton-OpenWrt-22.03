#
# Copyright (C) 2010-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tslib
PKG_VERSION:=1.23
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=\
  https://github.com/libts/tslib/releases/download/$(PKG_VERSION)/
PKG_HASH:=skip

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tslib
  SECTION:=nuvoton
  CATEGORY:=Nuvoton
  TITLE:=Touchscreen access library
#  DEPENDS:=+libpthread +librt
  URL:=http://tslib.org/
#  ABI_VERSION:=0
endef

define Package/tslib/description
  Tslib is a filtering layer for touchscreen panel events.
endef

TARGET_CFLAGS += $(FPIC)
#CONFIGURE_ARGS += \
#	--disable-udev \
#	--disable-log

define Build/InstallDev
endef

#define Package/tslib/conffiles
#/etc/pointercal
#endef

define Package/tslib/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/ts.conf $(1)/etc/
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/tslib.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,tslib))
