#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-examples
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/linaro-swg/optee_examples.git
# tag 4.0.0
PKG_SOURCE_DATE:=2023-04-11
PKG_SOURCE_VERSION:=378dc0db2d5dd279f58a3b6cb3f78ffd6b165035
PKG_MIRROR_HASH:=c23f47641df9b550a10c7ee7d7f3bee94a3a8d413508199a9f55148efda87a92
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk
include /tmp/openwrt.boot

define Package/optee-examples
  SECTION:=nuvoton
  CATEGORY:=Nuvoton
  DEPENDS:= +optee-ma35d1 +optee-client
  TITLE:=OP-TEE Sample Applications
  URL:=$(PKG_SOURCE_URL)
endef

MAKE_FLAGS += HOST_CROSS_COMPILE=$(GNU_TARGET_NAME)- TA_DEV_KIT_DIR=$(OPTEE_TA_DIR)

define Package/optee-examples/install
	$(INSTALL_DIR) $(1)/lib/optee_armtz/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/ta/*.ta $(1)/lib/optee_armtz/
	$(INSTALL_DIR) $(1)/usr/lib/tee-supplicant/plugins/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/plugins/*.plugin $(1)/usr/lib/tee-supplicant/plugins/
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/ca/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,optee-examples))
