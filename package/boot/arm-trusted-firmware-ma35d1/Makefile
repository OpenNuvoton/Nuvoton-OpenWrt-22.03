#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arm-trusted-firmware-ma35d1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/OpenNuvoton/MA35D1_arm-trusted-firmware-v2.3.git
PKG_SOURCE_DATE:=2024-01-29
PKG_SOURCE_VERSION:=f7f3ae7f7dfa6997eb7eb8e9d31594e056259c2b
PKG_MIRROR_HASH:=60ad77716221b93442883b8d90f6d1eb577571f68e5d8e4f685a8153b49bf332

PKG_MAINTAINER:=Chih-Chiang Chang <ccchang12@nuvoton.com>

PKG_LICENSE_FILES:=LICENCE.ma35d1

include $(INCLUDE_DIR)/trusted-firmware-a.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define Trusted-Firmware-A/Default
  BUILD_TARGET:=ma35d1
  PLAT:=ma35d1
  TFA_IMAGE:=bl2.bin bl31.bin
  BOOT_DEVICE:=
  DDR_BLOB:=
endef

define Trusted-Firmware-A/cpu800
  NAME:=MA35D1 CPU@800MHz
  CPU:=cpu800
endef

define Trusted-Firmware-A/cpu1g
  NAME:=MA35D1 CPU@1GHz
  CPU:=cpu1g
endef

TFA_TARGETS:= \
	cpu800 \
	cpu1g

TFA_MAKE_FLAGS += NEED_BL32=yes all dtbs fiptool

ifeq ($(SUBTARGET),iot)
  TFA_MAKE_FLAGS += MA35D1_PMIC=0
else ifeq ($(SUBTARGET),som)
  TFA_MAKE_FLAGS += MA35D1_PMIC=0
endif

ifeq ($(CONFIG_MA35D1_SECURE_BOOT),y)
  TFA_MAKE_FLAGS += FIP_DE_AES=1
endif

$(info PROFILE = $(PROFILE))
ifneq ($(findstring 128m,$(PROFILE)),)
  TFA_DTB_NAME:=ma35d1-cpu800-custom-ddr
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x07800000 MA35D1_DDR_MAX_SIZE=0x08000000 \
		    MA35D1_DRAM_S_BASE=0x87800000 MA35D1_BL32_BASE=0x87800000
else ifneq ($(findstring 256m,$(PROFILE)),)
  TFA_DTB_NAME:=ma35d1-cpu800-custom-ddr
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x0F800000 MA35D1_DDR_MAX_SIZE=0x10000000 \
		    MA35D1_DRAM_S_BASE=0x8F800000 MA35D1_BL32_BASE=0x8F800000
else ifneq ($(findstring 512m,$(PROFILE)),)
  TFA_DTB_NAME:=ma35d1-cpu800-custom-ddr
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x1F800000 MA35D1_DDR_MAX_SIZE=0x20000000 \
		    MA35D1_DRAM_S_BASE=0x9F800000 MA35D1_BL32_BASE=0x9F800000
else
  TFA_DTB_NAME:=ma35d1-cpu800-custom-ddr
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x3F800000 MA35D1_DDR_MAX_SIZE=0x40000000 \
		    MA35D1_DRAM_S_BASE=0xAF800000 MA35D1_BL32_BASE=0xAF800000
endif

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(SUBTARGET),iot)
ifneq ($(findstring 128m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16F787C_LQFP-216_MCP_WinbondDDR2_128M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/ma35d1/include/custom_ddr.h
else ifneq ($(findstring 256m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16F887C_LQFP-216_MCP_WinbondDDR3L_256M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/ma35d1/include/custom_ddr.h
else ifneq ($(findstring 512m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16F987C_LQFP-216_MCP_WinbondDDR3L_512M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/ma35d1/include/custom_ddr.h
endif
else ifeq ($(SUBTARGET),som)
ifneq ($(findstring 256m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16A887C_LFBGA-312_MCP_WinbondDDR3L_256M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/ma35d1/include/custom_ddr.h
endif
endif
endef

define Package/trusted-firmware-a/install
	touch /tmp/openwrt.boot
	sed -i /^TFA_/d /tmp/openwrt.boot
	echo TFA_DTB_NAME=$(subst cpu800,$(CPU),$(TFA_DTB_NAME)) >> /tmp/openwrt.boot
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/ma35d1/release/bl2.bin $(STAGING_DIR_IMAGE)/bl2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/ma35d1/release/bl31.bin $(STAGING_DIR_IMAGE)/bl31.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/ma35d1/release/fdts/$(subst cpu800,$(CPU),$(TFA_DTB_NAME)).dtb $(STAGING_DIR_IMAGE)/bl2.dtb
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/fiptool/fiptool $(STAGING_DIR_IMAGE)/fiptool
endef

$(eval $(call BuildPackage/Trusted-Firmware-A))
