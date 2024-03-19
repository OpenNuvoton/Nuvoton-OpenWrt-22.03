#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-examples
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/linaro-swg/optee_examples.git
# Buildroot uses 3.11.0
PKG_SOURCE_DATE:=2020-09-28
PKG_SOURCE_VERSION:=9a7dc598591990349d88b4dba3a37aadd6851295
PKG_MIRROR_HASH:=d3e45470dee10edcde22b8ebe2e2fd3044260557f7178c3c2918dc6526fba64e
# Yocto uses 3.9.0
#PKG_SOURCE_DATE:=2020-04-15
#PKG_SOURCE_VERSION:=f7f5a3ad2e8601bf2f846992d0b10aae3e3e5530
#PKG_MIRROR_HASH:=a98b7d9322ff624a76aef786d4688f40029a0eca6374d9a0cfdbd00b3b1bf474
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
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/ca/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,optee-examples))
