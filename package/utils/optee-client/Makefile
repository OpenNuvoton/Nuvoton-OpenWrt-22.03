#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-client
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OP-TEE/optee_client.git
# Buildroot uses 3.11.0
PKG_SOURCE_DATE:=2020-10-14
PKG_SOURCE_VERSION:=c0c925384c1d7e3558d27d2708857482952d7907
PKG_MIRROR_HASH:=4e2a562e74f38e7f17a30a1f83881e9b74d4b66940d2f340f9f854ee3e12db8d
# Yocto uses 3.12.0
#PKG_SOURCE_DATE:=2021-01-20
#PKG_SOURCE_VERSION:=347144b79964233e718347e3f0fbe89ab5be46ae
#PKG_MIRROR_HASH:=a5543d796ec78a9f397b6ea5af4fd0da16a4a0254e3104f44e75360e3cd379f9
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define Package/optee-client
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=@TARGET_ma35d1
  TITLE:=Normal World Client side of the TEE
  URL:=$(PKG_SOURCE_URL)
endef

MAKE_FLAGS += EXPORT_DIR=$(STAGING_DIR)

define Package/optee-client/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/libteec/libteec.so* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/libteec/libteec.a $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/libckteec/libckteec.so* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/libckteec/libckteec.a $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/tee-supplicant/tee-supplicant $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/tee-supplicant $(1)/etc/init.d/tee-supplicant
endef

$(eval $(call BuildPackage,optee-client))
