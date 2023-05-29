#!/usr/bin/env bash

ENV_SETUP_FILE=${STAGING_DIR_HOST}/${BOARD}-env-setup

if echo $ARCH | grep -q "aarch64"; then
	LINUX_KARCH=arm64
else
	LINUX_KARCH=$ARCH
fi

echo "cat <<'EOF'" > ${ENV_SETUP_FILE}
echo "" >> ${ENV_SETUP_FILE}
echo "       Making embedded Linux easy!" >> ${ENV_SETUP_FILE}
echo "" >> ${ENV_SETUP_FILE}
echo "Some tips:" >> ${ENV_SETUP_FILE}
echo "* PATH now contains the SDK utilities" >> ${ENV_SETUP_FILE}
echo "* Standard autotools variables (CC, LD, CFLAGS) are exported" >> ${ENV_SETUP_FILE}
echo "* Kernel compilation variables (ARCH, CROSS_COMPILE, KERNELDIR) are exported" >> ${ENV_SETUP_FILE}
echo "" >> ${ENV_SETUP_FILE}
echo "EOF" >> ${ENV_SETUP_FILE}

echo "export \"AR="${ARCH}"-openwrt-linux-ar"\" >> ${ENV_SETUP_FILE}
echo "export \"AS="${ARCH}"-openwrt-linux-as"\" >> ${ENV_SETUP_FILE}
echo "export \"LD="${ARCH}"-openwrt-linux-ld"\" >> ${ENV_SETUP_FILE}
echo "export \"NM="${ARCH}"-openwrt-linux-nm"\" >> ${ENV_SETUP_FILE}
echo "export \"CC="${ARCH}"-openwrt-linux-gcc"\" >> ${ENV_SETUP_FILE}
echo "export \"GCC="${ARCH}"-openwrt-linux-gcc"\" >> ${ENV_SETUP_FILE}
echo "export \"CPP="${ARCH}"-openwrt-linux-cpp"\" >> ${ENV_SETUP_FILE}
echo "export \"CXX="${ARCH}"-openwrt-linux-g++"\" >> ${ENV_SETUP_FILE}
echo "export \"RANLIB="${ARCH}"-openwrt-linux-ranlib"\" >> ${ENV_SETUP_FILE}
echo "export \"READELF="${ARCH}"-openwrt-linux-readelf"\" >> ${ENV_SETUP_FILE}
echo "export \"STRIP="${ARCH}"-openwrt-linux-strip"\" >> ${ENV_SETUP_FILE}
echo "export \"OBJCOPY="${ARCH}"-openwrt-linux-objcopy"\" >> ${ENV_SETUP_FILE}
echo "export \"OBJDUMP="${ARCH}"-openwrt-linux-objdump"\" >> ${ENV_SETUP_FILE}
echo "export \"CPPFLAGS="${TARGET_CPPFLAGS}\" >> ${ENV_SETUP_FILE}
echo "export \"CFLAGS="${TARGET_CFLAGS}\" >> ${ENV_SETUP_FILE}
echo "export \"CXXFLAGS="${TARGET_CXXFLAGS}\" >> ${ENV_SETUP_FILE}
echo "export \"STAGING_DIR="${STAGING_DIR}\" >> ${ENV_SETUP_FILE}
echo "export \"ARCH="${LINUX_KARCH}\" >> ${ENV_SETUP_FILE}
echo "export \"CROSS_COMPILE="${ARCH}"-openwrt-linux-"\" >> ${ENV_SETUP_FILE}
echo "export \"PATH="${TOOLCHAIN_DIR}/bin:\$PATH\" >> ${ENV_SETUP_FILE}
echo "export \"KERNELDIR="${LINUX_DIR}\" >> ${ENV_SETUP_FILE}

