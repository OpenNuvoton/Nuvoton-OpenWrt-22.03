PKG_NAME ?= optee

ifndef PKG_SOURCE_PROTO
PKG_SOURCE = $(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/OP-TEE/optee_os.git
endif

PKG_BUILD_DIR = $(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_TARGETS := bin
PKG_FLAGS:=nonshared

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

export GCC_HONOUR_COPTS=s

define Package/optee/install/default
	$(CP) $(patsubst %,$(PKG_BUILD_DIR)/out/core/%,$(OPTEE_IMAGE)) $(1)/
endef

Package/optee/install = $(Package/optee/install/default)

define Optee/Init
  BUILD_TARGET:=
  BUILD_SUBTARGET:=
  BUILD_DEVICES:=
  NAME:=
  DEPENDS:=
  HIDDEN:=
  DEFAULT:=
  PLATFORM:=
  VARIANT:=$(1)
  OPTEE_IMAGE:=
endef

TARGET_DEP = TARGET_$(BUILD_TARGET)$(if $(BUILD_SUBTARGET),_$(BUILD_SUBTARGET))

define Build/Optee/Target
  $(eval $(call Optee/Init,$(1)))
  $(eval $(call Optee/Default,$(1)))
  $(eval $(call Optee/$(1),$(1)))

 define Package/optee-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    TITLE:=Optee for $(NAME)
    VARIANT:=$(VARIANT)
    DEPENDS:=@!IN_SDK $(DEPENDS)
    HIDDEN:=$(HIDDEN)
    ifneq ($(BUILD_TARGET),)
      DEPENDS += @$(TARGET_DEP)
      ifneq ($(BUILD_DEVICES),)
        DEFAULT := y if ($(TARGET_DEP)_Default \
		$(patsubst %,|| $(TARGET_DEP)_DEVICE_%,$(BUILD_DEVICES)) \
		$(patsubst %,|| $(patsubst TARGET_%,TARGET_DEVICE_%,$(TARGET_DEP))_DEVICE_%,$(BUILD_DEVICES)))
      endif
    endif
    $(if $(DEFAULT),DEFAULT:=$(DEFAULT))
    URL:=http://optee.readthedocs.io
  endef

  define Package/optee-$(1)/install
	$$(Package/optee/install)
  endef
endef


define Build/Compile/Optee
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE_core=$(TARGET_CROSS) \
		CROSS_COMPILE_ta_arm64=$(TARGET_CROSS) \
		PLATFORM=$(PLATFORM) \
		PLATFORM_FLAVOR=$(PLATFORM_FLAVOR) \
		$(OPTEE_MAKE_FLAGS)
endef

define BuildPackage/Optee/Defaults
  Build/Configure/Default = $$$$(Build/Configure/Optee)
  Build/Compile/Default = $$$$(Build/Compile/Optee)
endef

define BuildPackage/Optee
  $(eval $(call BuildPackage/Optee/Defaults))
  $(foreach type,$(if $(DUMP),$(OPTEE_TARGETS),$(BUILD_VARIANT)), \
    $(eval $(call Build/Optee/Target,$(type)))
  )
  $(eval $(call Build/DefaultTargets))
  $(foreach type,$(if $(DUMP),$(OPTEE_TARGETS),$(BUILD_VARIANT)), \
    $(call BuildPackage,optee-$(type))
  )
endef
