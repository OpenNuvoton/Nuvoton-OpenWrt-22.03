#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=optee-ma35d1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenNuvoton/MA35D1_optee_os-v3.9.0.git
PKG_SOURCE_DATE:=2022-11-28
PKG_SOURCE_VERSION:=49e947a8e7dc8304d4d6deb20f00d7f4caabab50
PKG_MIRROR_HASH:=c6405b3ff206e117b161316cf772ee854e49b71ec665e6fe2df736efb7eabc7d
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define Package/optee-ma35d1
  SECTION:=boot
  CATEGORY:=Boot Loaders
  DEPENDS:=@TARGET_ma35d1
  TITLE:=MA35D1 OP-TEE
  URL:=$(PKG_SOURCE_URL)
  PLATFORM:=nuvoton
  PLATFORM_FLAVOR:=MA35D1
endef

OPTEE_MAKE_FLAGS += all

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
		PLATFORM_FLAVOR=$(PLATFORM_FLAVOR) \
		$(OPTEE_MAKE_FLAGS)
endef

define Package/optee-ma35d1/install
	touch /tmp/openwrt.boot
	sed -i /^OPTEE_/d /tmp/openwrt.boot
	echo OPTEE_PROFILE=$(PROFILE) >> /tmp/openwrt.boot
	echo OPTEE_TA_DIR=$(PKG_BUILD_DIR)/out/arm-plat-nuvoton/export-ta_arm64 >> /tmp/openwrt.boot

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-nuvoton/core/tee.bin $(STAGING_DIR_IMAGE)/tee.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-nuvoton/core/tee-pager_v2.bin $(STAGING_DIR_IMAGE)/tee-pager_v2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-nuvoton/core/tee-pageable_v2.bin $(STAGING_DIR_IMAGE)/tee-pageable_v2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-nuvoton/core/tee-header_v2.bin $(STAGING_DIR_IMAGE)/tee-header_v2.bin

	$(INSTALL_DIR) $(1)/lib/optee_armtz/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-nuvoton/*/*/*.ta $(1)/lib/optee_armtz/
endef

$(eval $(call BuildPackage,optee-ma35d1))
