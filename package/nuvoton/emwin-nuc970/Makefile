include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=emwin-nuc970
PKG_VERSION:=1.0
PKG_RELEASE:=$(AUTORELEASE)

# Source settings (i.e. where to find the source codes)
# This is a custom variable, used below
PKG_SOURCE:=N9H30_Linux_emWin_Package

include $(INCLUDE_DIR)/package.mk

# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/emwin-nuc970
  SECTION:=nuvoton
  CATEGORY:=Nuvoton
  DEPENDS:=@TARGET_nuc970 +tslib
  TITLE:=emWin Sample Applications
endef

# Package description; a more verbose description on what our package does
define Package/emwin-nuc970/description
  The demo applications of Nuvoton emWin.
endef

# Package preparation instructions; create the build directory and copy the source code. 
# The last command is necessary to ensure our preparation instructions remain compatible with the patching system.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(PKG_SOURCE) $(PKG_BUILD_DIR)/$(PKG_SOURCE)
	$(Build/Patch)
endef

#ifneq ($(findstring musl,$(TOOLCHAIN_DIR)),)
ifneq ($(CONFIG_LIBC_USE_MUSL),)
	EMWIN_LDFLAGS = -L../../Lib -lNUemWin_musl -lm -L../../../../tslib-1.23/src/.libs -lts -ldl -pthread
else
	EMWIN_LDFLAGS = -L../../Lib -lNUemWin -lm -L../../../../tslib-1.23/src/.libs -lts -ldl -pthread
endif
$(info EMWIN_LDFLAGS = $(EMWIN_LDFLAGS))

# Package build instructions; invoke the target-specific compiler to first compile the source file, and then to link the file into the final executable
define Build/Compile
	for subdir in $(PKG_BUILD_DIR)/$(PKG_SOURCE)/Sample/* ; do \
		$(MAKE) -C "$$$$subdir" \
			CC="$(TARGET_CC)" \
			STRIP="$(TARGET_CROSS)strip" \
			CFLAGS="$(TARGET_CFLAGS) -Wall" \
			LDFLAGS="$(TARGET_LDFLAGS) $(EMWIN_LDFLAGS)" ; \
	done
endef


# Package install instructions; create a directory inside the package to hold our executable, and then copy the executable we built previously into the folder
define Package/emwin-nuc970/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_SOURCE)/Sample/GUIDemo/GUIDemo $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_SOURCE)/Sample/SimpleDemo/SimpleDemo $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_SOURCE)/Sample/SimpleDemoAppWizard/SimpleDemoAppWizard $(1)/usr/bin
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,emwin-nuc970))
