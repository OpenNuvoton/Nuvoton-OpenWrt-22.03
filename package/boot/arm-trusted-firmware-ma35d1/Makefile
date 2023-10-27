#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arm-trusted-firmware-ma35d1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/OpenNuvoton/MA35D1_arm-trusted-firmware-v2.3.git
PKG_SOURCE_DATE:=2023-10-02
PKG_SOURCE_VERSION:=bfdc580e39a8e4727f8f33764e442b9326331047
PKG_MIRROR_HASH:=c4331badaecb68690e41b3bb0e6df1feb0b4e3c0f63c4c8cbaa39039c5a93055

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
  TFA_DTB_NAME:=ma35d1-cpu800-wb-128m
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x07800000 MA35D1_DDR_MAX_SIZE=0x08000000 \
		    MA35D1_DRAM_S_BASE=0x87800000 MA35D1_BL32_BASE=0x87800000
else ifneq ($(findstring 256m,$(PROFILE)),)
  TFA_DTB_NAME:=ma35d1-cpu800-wb-256m
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x0F800000 MA35D1_DDR_MAX_SIZE=0x10000000 \
		    MA35D1_DRAM_S_BASE=0x8F800000 MA35D1_BL32_BASE=0x8F800000
else ifneq ($(findstring 512m,$(PROFILE)),)
  TFA_DTB_NAME:=ma35d1-cpu800-wb-512m
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x1F800000 MA35D1_DDR_MAX_SIZE=0x20000000 \
		    MA35D1_DRAM_S_BASE=0x9F800000 MA35D1_BL32_BASE=0x9F800000
else
  TFA_DTB_NAME:=ma35d1-cpu800-mc-1g
  TFA_MAKE_FLAGS += MA35D1_DRAM_SIZE=0x3F800000 MA35D1_DDR_MAX_SIZE=0x40000000 \
		    MA35D1_DRAM_S_BASE=0xAF800000 MA35D1_BL32_BASE=0xAF800000
endif

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
