#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-test
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OP-TEE/optee_test.git
# tag 4.0.0
PKG_SOURCE_DATE:=2023-05-29
PKG_SOURCE_VERSION:=1c3d6be5eaa6174e3dbabf60928d15628e39b994
PKG_MIRROR_HASH:=d18360454530422503bc0726011f0b2b2d97197d3d4adc789f2435e0255fe1be
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk
include /tmp/openwrt.boot

define Package/optee-test
  SECTION:=nuvoton
  CATEGORY:=Nuvoton
  DEPENDS:= +optee-ma35d1 +optee-client +libopenssl
  TITLE:=OP-TEE Test suite
  URL:=$(PKG_SOURCE_URL)
endef

MAKE_FLAGS += CROSS_COMPILE=$(GNU_TARGET_NAME)- TA_DEV_KIT_DIR=$(OPTEE_TA_DIR) OPTEE_CLIENT_EXPORT=$(STAGING_DIR)/usr
LDFLAGS += -L$(STAGING_DIR)/usr/lib -lcrypto
CFLAGS += -I$(STAGING_DIR)/usr/include

define Package/optee-test/install
	$(INSTALL_DIR) $(1)/lib/optee_armtz/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/ta/*/*.ta $(1)/lib/optee_armtz/
	$(INSTALL_DIR) $(1)/usr/lib/tee-supplicant/plugins/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/supp_plugin/*.plugin $(1)/usr/lib/tee-supplicant/plugins/
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/xtest/xtest $(1)/usr/bin/
endef

$(eval $(call BuildPackage,optee-test))
