#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-ma35d1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/optee_os_ma35.git
PKG_SOURCE_DATE:=2025-03-28
PKG_SOURCE_VERSION:=526c77576bcf259e413865d32243e65960c86dc9
PKG_MIRROR_HASH:=9cef2228f33355103869fa3d00e62977c0d79f937fbaa44a24e5e33add8b23c3
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define Package/optee-ma35d1
  SECTION:=boot
  CATEGORY:=Boot Loaders
  DEPENDS:=@(TARGET_ma35d1||TARGET_ma35d0)
  TITLE:=OP-TEE OS for MA35 board
  URL:=$(PKG_SOURCE_URL)
  PLATFORM:=ma35
endef

ifeq ($(BOARD),ma35d1)
  OPTEE_MAKE_FLAGS += PLATFORM_FLAVOR=MA35D1 all
else ifeq ($(BOARD),ma35h0)
  OPTEE_MAKE_FLAGS += PLATFORM_FLAVOR=MA35H0 all
else ifeq ($(BOARD),ma35d0)
  OPTEE_MAKE_FLAGS += PLATFORM_FLAVOR=MA35D0 all
endif

$(info PROFILE = $(PROFILE))
ifneq ($(findstring 128m,$(PROFILE)),)
  OPTEE_MAKE_FLAGS += CFG_TZDRAM_START=0x87800000 CFG_SHMEM_START=0x87F00000
else ifneq ($(findstring 256m,$(PROFILE)),)
  OPTEE_MAKE_FLAGS += CFG_TZDRAM_START=0x8F800000 CFG_SHMEM_START=0x8FF00000
else ifneq ($(findstring 512m,$(PROFILE)),)
  OPTEE_MAKE_FLAGS += CFG_TZDRAM_START=0x9F800000 CFG_SHMEM_START=0x9FF00000
else
  OPTEE_MAKE_FLAGS += CFG_TZDRAM_START=0xAF800000 CFG_SHMEM_START=0xAFF00000
endif

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE_core=$(TARGET_CROSS) \
		CROSS_COMPILE_ta_arm64=$(TARGET_CROSS) \
		PLATFORM=$(PLATFORM) \
		$(OPTEE_MAKE_FLAGS)
endef

define Package/optee-ma35d1/install
	touch /tmp/openwrt.boot
	sed -i /^OPTEE_/d /tmp/openwrt.boot
	echo OPTEE_PROFILE=$(PROFILE) >> /tmp/openwrt.boot
	echo OPTEE_TA_DIR=$(PKG_BUILD_DIR)/out/arm-plat-ma35/export-ta_arm64 >> /tmp/openwrt.boot

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-ma35/core/tee.bin $(STAGING_DIR_IMAGE)/tee.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-ma35/core/tee-pager_v2.bin $(STAGING_DIR_IMAGE)/tee-pager_v2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-ma35/core/tee-header_v2.bin $(STAGING_DIR_IMAGE)/tee-header_v2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-ma35/core/tee-pageable_v2.bin $(STAGING_DIR_IMAGE)/tee-pageable_v2.bin

	$(INSTALL_DIR) $(1)/lib/optee_armtz/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-ma35/export-ta_arm64/ta/*.ta $(1)/lib/optee_armtz/
endef

$(eval $(call BuildPackage,optee-ma35d1))
