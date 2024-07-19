#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arm-trusted-firmware-ma35d1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/OpenNuvoton/MA35D1_arm-trusted-firmware-v2.3.git
PKG_SOURCE_DATE:=2024-06-18
PKG_SOURCE_VERSION:=7eba1fcbbaf0ce62a2387a8e9aae70039e60be4a
PKG_MIRROR_HASH:=a57eeb21fd50879261eabb926f1934a21b659505624478fec0ceca20e3cb5922

PKG_MAINTAINER:=Chih-Chiang Chang <ccchang12@nuvoton.com>

PKG_LICENSE_FILES:=LICENCE.ma35d1

include $(INCLUDE_DIR)/trusted-firmware-a.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk

define Package/trusted-firmware-a-ma35d1/config
  source "$(SOURCE)/Config.in"
endef

define Trusted-Firmware-A/Default
  BUILD_TARGET:=$(BOARD)
  PLAT:=$(BOARD)
  TFA_IMAGE:=bl2.bin bl31.bin
  DEPENDS:=@(TARGET_ma35d1||TARGET_ma35d0||TARGET_ma35h0)
endef

define Trusted-Firmware-A/ma35d1
  NAME:=MA35 board
endef

TFA_TARGETS:=ma35d1

TFA_MAKE_FLAGS += PLAT=$(BOARD) all dtbs fiptool
ifeq ($(CONFIG_TFA_LOAD_SCP_BL2),y)
  TFA_MAKE_FLAGS += NEED_SCP_BL2=yes
endif
ifeq ($(CONFIG_PACKAGE_optee-ma35d1),y)
  TFA_MAKE_FLAGS += NEED_BL32=yes
endif

ifeq ($(BOARD),ma35d1)
ifeq ($(CONFIG_TFA_PMIC_AUTO),y)
ifeq ($(SUBTARGET),iot)
  TFA_MAKE_FLAGS += MA35D1_PMIC=0
else ifeq ($(SUBTARGET),som)
  TFA_MAKE_FLAGS += MA35D1_PMIC=1
endif
else ifeq ($(CONFIG_TFA_PMIC_0),y)
  TFA_MAKE_FLAGS += MA35D1_PMIC=0
else ifeq ($(CONFIG_TFA_PMIC_1),y)
  TFA_MAKE_FLAGS += MA35D1_PMIC=1
else ifeq ($(CONFIG_TFA_PMIC_2),y)
  TFA_MAKE_FLAGS += MA35D1_PMIC=2
else ifeq ($(CONFIG_TFA_PMIC_3),y)
  TFA_MAKE_FLAGS += MA35D1_PMIC=3
endif
else ifeq ($(BOARD),ma35h0)
ifeq ($(CONFIG_TFA_PMIC_AUTO),y)
  TFA_MAKE_FLAGS += MA35H0_PMIC=0
else ifeq ($(CONFIG_TFA_PMIC_0),y)
  TFA_MAKE_FLAGS += MA35H0_PMIC=0
else ifeq ($(CONFIG_TFA_PMIC_1),y)
  TFA_MAKE_FLAGS += MA35H0_PMIC=1
else ifeq ($(CONFIG_TFA_PMIC_2),y)
  TFA_MAKE_FLAGS += MA35H0_PMIC=2
else ifeq ($(CONFIG_TFA_PMIC_3),y)
  TFA_MAKE_FLAGS += MA35H0_PMIC=3
endif
else ifeq ($(BOARD),ma35d0)
ifeq ($(CONFIG_TFA_PMIC_AUTO),y)
  TFA_MAKE_FLAGS += MA35D0_PMIC=0
else ifeq ($(CONFIG_TFA_PMIC_0),y)
  TFA_MAKE_FLAGS += MA35D0_PMIC=0
else ifeq ($(CONFIG_TFA_PMIC_1),y)
  TFA_MAKE_FLAGS += MA35D0_PMIC=1
else ifeq ($(CONFIG_TFA_PMIC_2),y)
  TFA_MAKE_FLAGS += MA35D0_PMIC=2
else ifeq ($(CONFIG_TFA_PMIC_3),y)
  TFA_MAKE_FLAGS += MA35D0_PMIC=3
endif
endif

ifeq ($(CONFIG_MA35D1_SECURE_BOOT),y)
  TFA_MAKE_FLAGS += FIP_DE_AES=1
else ifeq ($(CONFIG_MA35H0_SECURE_BOOT),y)
  TFA_MAKE_FLAGS += FIP_DE_AES=1
else ifeq ($(CONFIG_MA35D0_SECURE_BOOT),y)
  TFA_MAKE_FLAGS += FIP_DE_AES=1
endif

$(info PROFILE = $(PROFILE))
ifeq ($(BOARD),ma35d1)
ifeq ($(CONFIG_TFA_CPU1G),y)
  TFA_DTB_NAME:=ma35d1-cpu1g-custom-ddr
else
  TFA_DTB_NAME:=ma35d1-cpu800-custom-ddr
endif
ifneq ($(findstring 128m,$(PROFILE)),)
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x07800000 MA35D1_DDR_MAX_SIZE=0x08000000 \
		    MA35D1_DRAM_S_BASE=0x87800000 MA35D1_BL32_BASE=0x87800000
else ifneq ($(findstring 256m,$(PROFILE)),)
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x0F800000 MA35D1_DDR_MAX_SIZE=0x10000000 \
		    MA35D1_DRAM_S_BASE=0x8F800000 MA35D1_BL32_BASE=0x8F800000
else ifneq ($(findstring 512m,$(PROFILE)),)
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x1F800000 MA35D1_DDR_MAX_SIZE=0x20000000 \
		    MA35D1_DRAM_S_BASE=0x9F800000 MA35D1_BL32_BASE=0x9F800000
else
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x3F800000 MA35D1_DDR_MAX_SIZE=0x40000000 \
		    MA35D1_DRAM_S_BASE=0xAF800000 MA35D1_BL32_BASE=0xAF800000
endif
else ifeq ($(BOARD),ma35h0)
  TFA_DTB_NAME:=ma35h0-cpu650-custom-ddr
ifneq ($(findstring 128m,$(PROFILE)),)
  TFA_MAKE_FLAGS += MA35H0_DRAM_SIZE=0x7F800000 MA35H0_DDR_MAX_SIZE=0x80000000 \
		    MA35H0_DRAM_S_BASE=0xFF800000 MA35H0_BL32_BASE=0xFF800000
endif
else ifeq ($(BOARD),ma35d0)
  TFA_DTB_NAME:=ma35d0-cpu650-custom-ddr
ifneq ($(findstring 128m,$(PROFILE)),)
  TFA_MAKE_FLAGS += MA35D0_DRAM_SIZE=0x7F800000 MA35D0_DDR_MAX_SIZE=0x80000000 \
		    MA35D0_DRAM_S_BASE=0xFF800000 MA35D0_BL32_BASE=0xFF800000
else ifneq ($(findstring 256m,$(PROFILE)),)
  TFA_MAKE_FLAGS += MA35D0_DRAM_SIZE=0x0F800000 MA35D0_DDR_MAX_SIZE=0x10000000 \
		    MA35D0_DRAM_S_BASE=0x8F800000 MA35D0_BL32_BASE=0x8F800000
endif
endif

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(CONFIG_TFA_CUSTOM_DDR_FILE_AUTO),y)
ifeq ($(BOARD),ma35d1)
ifeq ($(SUBTARGET),iot)
ifneq ($(findstring 128m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16F787C_LQFP-216_MCP_WinbondDDR2_128M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
else ifneq ($(findstring 256m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16F887C_LQFP-216_MCP_WinbondDDR3L_256M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
else ifneq ($(findstring 512m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16F987C_LQFP-216_MCP_WinbondDDR3L_512M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
endif
else ifeq ($(SUBTARGET),som)
ifneq ($(findstring 256m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D16A887C_LFBGA-312_MCP_WinbondDDR3L_256M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
endif
endif
else ifeq ($(BOARD),ma35h0)
ifeq ($(SUBTARGET),hmi)
ifneq ($(findstring 128m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35H04F764C_MCP_WBDDR2_128M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
endif
endif
else ifeq ($(BOARD),ma35d0)
ifeq ($(SUBTARGET),iot)
ifneq ($(findstring 128m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D03F764C_MCP_WBDDR2_128M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
else ifneq ($(findstring 256m,$(PROFILE)),)
	$(CP) $(TOPDIR)/Nuvoton/ddr/MA35D03F864C_MCP_WBDDR3L_256M_1PCS.h $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
endif
endif
endif
else
	$(CP) $(TOPDIR)/Nuvoton/ddr/$(CONFIG_TFA_CUSTOM_DDR_FILE) $(PKG_BUILD_DIR)/plat/nuvoton/$(BOARD)/include/custom_ddr.h
endif
endef

define Package/trusted-firmware-a/install
	touch /tmp/openwrt.boot
	sed -i /^TFA_/d /tmp/openwrt.boot
	echo TFA_DTB_NAME=$(TFA_DTB_NAME) >> /tmp/openwrt.boot
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
ifeq ($(CONFIG_TFA_LOAD_SCP_BL2),y)
	$(INSTALL_DATA) $(TOPDIR)/Nuvoton/rtp/$(CONFIG_TFA_SCP_BL2_FILE) $(STAGING_DIR_IMAGE)/rtp.bin
endif
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/$(BOARD)/release/bl2.bin $(STAGING_DIR_IMAGE)/bl2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/$(BOARD)/release/bl31.bin $(STAGING_DIR_IMAGE)/bl31.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/$(BOARD)/release/fdts/$(TFA_DTB_NAME).dtb $(STAGING_DIR_IMAGE)/bl2.dtb
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/fiptool/fiptool $(STAGING_DIR_IMAGE)/fiptool
endef

$(eval $(call BuildPackage/Trusted-Firmware-A))
