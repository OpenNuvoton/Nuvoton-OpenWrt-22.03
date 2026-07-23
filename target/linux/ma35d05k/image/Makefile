#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

UBIFS_OPTS = -F -m 2048 -e 124KiB -c 4096 -U
UBI_OPTS = -m 2048 -p 128KiB -s 2048 -O 2048

include $(SUBTARGET).mk

#################################################
# Images
#################################################

DEVICE_VARS += MKUBIFS_OPTS UBOOT BOOT_SCRIPT

define Build/copy-dtb
	echo DEVICE_NAME=$(DEVICE_NAME) > /tmp/openwrt.env
	$(CP) $(KDIR)/$(DEVICE_DTS_CONFIG).dtb $(STAGING_DIR_IMAGE)/Image.dtb
endef

# Append the device tree blob into the sysupgrade tar so that OTA can also
# update the dedicated "device-tree" NAND partition.
define Build/append-dtb-tar
	mkdir -p $@.dtbdir/sysupgrade-$(DEVICE_NAME)
	$(CP) $(KDIR)/$(DEVICE_DTS_CONFIG).dtb \
		$@.dtbdir/sysupgrade-$(DEVICE_NAME)/dtb
	tar -C $@.dtbdir --owner=0 --group=0 --numeric-owner \
		-rf $@ sysupgrade-$(DEVICE_NAME)/dtb
	rm -rf $@.dtbdir
endef

define Build/sdcard-img
	$(info "Build/sdcard-img" $(1))
	SIGNATURE="$(IMG_PART_SIGNATURE)" \
	/usr/bin/bash ./gen_ma35d05k_sdcard_img.sh $@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) \
		${KDIR} \
		$(DEVICE_NAME) \
		$(KDIR)/$(DEVICE_DTS_CONFIG).dtb \
		$(CONFIG_TARGET_SDCARD_DATA_PARTSIZE)
endef

define Image/Build
	$(info "Image/Build" $(1))
ifeq ($(1),squashfs)
	mkdir -p $(PLATFORM_DIR)/base-files/lib/modules/5.10.140/
ifeq ($(CONFIG_LIBC_USE_MUSL),y)
	$(CP) ./modules/dcultrafb_musl.ko $(PLATFORM_DIR)/base-files/lib/modules/5.10.140/dcultrafb.ko
else
	$(CP) ./modules/dcultrafb_glibc.ko $(PLATFORM_DIR)/base-files/lib/modules/5.10.140/dcultrafb.ko
endif
endif
	$(call Image/Build/$(1),$(1))
ifeq ($(1),squashfs)
	echo ARCH=$(ARCH) >> /tmp/openwrt.env
	echo BOARD=$(BOARD) >> /tmp/openwrt.env
	echo SUBTARGET=$(SUBTARGET) >> /tmp/openwrt.env
	echo PROFILE=$(PROFILE) >> /tmp/openwrt.env
	echo TOPDIR=$(TOPDIR) >> /tmp/openwrt.env
	echo PLATFORM_DIR=$(PLATFORM_DIR) >> /tmp/openwrt.env
	echo KDIR=$(KDIR) >> /tmp/openwrt.env
	echo LINUX_DIR=$(LINUX_DIR) >> /tmp/openwrt.env
	echo BIN_DIR=$(BIN_DIR) >> /tmp/openwrt.env
	echo TOOLCHAIN_DIR=$(TOOLCHAIN_DIR) >> /tmp/openwrt.env
	echo TARGET_CROSS=\"$(TARGET_CROSS)\" >> /tmp/openwrt.env
	echo TARGET_CXXFLAGS=\"$(TARGET_CXXFLAGS)\" >> /tmp/openwrt.env
	echo TARGET_CFLAGS=\"$(TARGET_CFLAGS)\" >> /tmp/openwrt.env
	echo TARGET_CPPFLAGS=\"$(TARGET_CPPFLAGS)\" >> /tmp/openwrt.env
	echo GNU_TARGET_NAME=\"$(GNU_TARGET_NAME)\" >> /tmp/openwrt.env
	echo GNU_HOST_NAME=\"$(GNU_HOST_NAME)\" >> /tmp/openwrt.env
	echo STAGING_DIR=$(STAGING_DIR) >> /tmp/openwrt.env
	echo STAGING_DIR_HOST=$(STAGING_DIR_HOST) >> /tmp/openwrt.env
	echo STAGING_DIR_IMAGE=$(STAGING_DIR_IMAGE) >> /tmp/openwrt.env
	echo TARGET_FILESYSTEMS=\"$(TARGET_FILESYSTEMS)\" >> /tmp/openwrt.env
	echo CONFIG_TARGET_KERNEL_PARTSIZE=$(CONFIG_TARGET_KERNEL_PARTSIZE) >> /tmp/openwrt.env
	echo CONFIG_TARGET_ROOTFS_PARTSIZE=$(CONFIG_TARGET_ROOTFS_PARTSIZE) >> /tmp/openwrt.env
	echo CONFIG_TARGET_SDCARD_DATA_PARTSIZE=$(CONFIG_TARGET_SDCARD_DATA_PARTSIZE) >> /tmp/openwrt.env
ifeq ($(CONFIG_MA35D05K_SECURE_BOOT),y)
	echo CONFIG_MA35D05K_AES_KEY=$(CONFIG_MA35D05K_AES_KEY) >> /tmp/openwrt.env
	echo CONFIG_MA35D05K_ECDSA_KEY=$(CONFIG_MA35D05K_ECDSA_KEY) >> /tmp/openwrt.env
endif
	touch /tmp/openwrt.boot
	cat /tmp/openwrt.boot >> /tmp/openwrt.env
	env - BASH_ENV=/tmp/openwrt.env /bin/bash $(TOPDIR)/Nuvoton/script/ma35d05k-pack-image.sh
	env - BASH_ENV=/tmp/openwrt.env /bin/bash $(TOPDIR)/Nuvoton/script/env-setup.sh
endif
endef


#################################################
# Devices
#################################################

KERNEL_LOADADDR=0x00008000

define Device/select-dtb
  IMAGES += image-dtb
  IMAGE/image-dtb := copy-dtb
endef

define Device/Default
  PROFILES := Default
  KERNEL_INSTALL := 1
  KERNEL_SUFFIX := -uImage
  KERNEL_NAME := Image
  KERNEL := kernel-bin | gzip | uImage gzip
endef

ifeq ($(SUBTARGET),iotv1)
define Device/iotv1-nand
  IMAGE_SIZE := 32768k
  PAGESIZE := 2048
  BLOCKSIZE := 128k
  FILESYSTEMS := squashfs
  IMAGES := firmware.bin sysupgrade.bin
  IMAGE/firmware.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-ubi | sysupgrade-tar | append-dtb-tar | append-metadata | check-size $$$$(IMAGE_SIZE)
endef

define Device/iotv1-sdcard
  # CONFIG_TARGET_SDCARD_DATA_PARTSIZE selects the layout:
  #   > 0 : read-only squashfs root (p3) + writable ext4 "rootfs_data"
  #         overlay (p4), so OTA can preserve settings (mirrors squashfs+ubifs
  #         NAND).
  #   = 0 : a single writable ext4 root (p3), no overlay.
  FILESYSTEMS := $(if $(filter 0,$(CONFIG_TARGET_SDCARD_DATA_PARTSIZE)),ext4,squashfs)
  IMAGES := sysupgrade.gz
  IMAGE/sysupgrade.gz := sdcard-img | append-metadata | gzip
endef
endif

$(eval $(call BuildImage))
