#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-test
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OP-TEE/optee_test.git
# Buildroot uses 3.11.0
#PKG_SOURCE_DATE:=2020-10-08
#PKG_SOURCE_VERSION:=159e295d5cc3ad2275ab15fe544620f6604d4ba4
#PKG_MIRROR_HASH:=644c78185e2a7c652513e2c97cc727c7ba5a4550de820372f6729ee8e29e9b50
# Yocto uses 3.9.0 ~ 3.10.0
PKG_SOURCE_DATE:=2020-05-26
PKG_SOURCE_VERSION:=3ef6bf9e4b82df1ba0b381907c4d47cb23ad6bd5
PKG_MIRROR_HASH:=a0b0e2b07c679d0ae9fb2be5d29daa25d66f7a65d413a039e44a1bdc357e8526
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk
include /tmp/openwrt.boot

define Package/optee-test
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:= +optee-ma35d1 +optee-client
  TITLE:=OP-TEE Test suite
  URL:=$(PKG_SOURCE_URL)
endef

MAKE_FLAGS += CROSS_COMPILE=$(GNU_TARGET_NAME)- TA_DEV_KIT_DIR=$(OPTEE_TA_DIR) OPTEE_CLIENT_EXPORT=$(STAGING_DIR)/usr

define Package/optee-test/install
	$(INSTALL_DIR) $(1)/lib/optee_armtz/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/ta/*/*.ta $(1)/lib/optee_armtz/
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/xtest/xtest $(1)/usr/bin/
endef

$(eval $(call BuildPackage,optee-test))
