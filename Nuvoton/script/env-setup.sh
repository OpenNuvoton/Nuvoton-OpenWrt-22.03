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

echo "export \"AR="${GNU_TARGET_NAME}"-ar"\" >> ${ENV_SETUP_FILE}
echo "export \"AS="${GNU_TARGET_NAME}"-as"\" >> ${ENV_SETUP_FILE}
echo "export \"LD="${GNU_TARGET_NAME}"-ld"\" >> ${ENV_SETUP_FILE}
echo "export \"NM="${GNU_TARGET_NAME}"-nm"\" >> ${ENV_SETUP_FILE}
echo "export \"CC="${GNU_TARGET_NAME}"-gcc"\" >> ${ENV_SETUP_FILE}
echo "export \"GCC="${GNU_TARGET_NAME}"-gcc"\" >> ${ENV_SETUP_FILE}
echo "export \"CPP="${GNU_TARGET_NAME}"-cpp"\" >> ${ENV_SETUP_FILE}
echo "export \"CXX="${GNU_TARGET_NAME}"-g++"\" >> ${ENV_SETUP_FILE}
echo "export \"RANLIB="${GNU_TARGET_NAME}"-ranlib"\" >> ${ENV_SETUP_FILE}
echo "export \"READELF="${GNU_TARGET_NAME}"-readelf"\" >> ${ENV_SETUP_FILE}
echo "export \"STRIP="${GNU_TARGET_NAME}"-strip"\" >> ${ENV_SETUP_FILE}
echo "export \"OBJCOPY="${GNU_TARGET_NAME}"-objcopy"\" >> ${ENV_SETUP_FILE}
echo "export \"OBJDUMP="${GNU_TARGET_NAME}"-objdump"\" >> ${ENV_SETUP_FILE}
echo "export \"CPPFLAGS="${TARGET_CPPFLAGS}\" >> ${ENV_SETUP_FILE}
echo "export \"CFLAGS="${TARGET_CFLAGS}\" >> ${ENV_SETUP_FILE}
echo "export \"CXXFLAGS="${TARGET_CXXFLAGS}\" >> ${ENV_SETUP_FILE}
echo "export \"STAGING_DIR="${STAGING_DIR}\" >> ${ENV_SETUP_FILE}
echo "export \"ARCH="${LINUX_KARCH}\" >> ${ENV_SETUP_FILE}
echo "export \"CROSS_COMPILE="${GNU_TARGET_NAME}"-"\" >> ${ENV_SETUP_FILE}
echo "export \"CONFIGURE_FLAGS=--target="${GNU_TARGET_NAME}" \
--host="${GNU_TARGET_NAME}" \
--build="${GNU_HOST_NAME}" \
--prefix="${TOOLCHAIN_DIR}"/usr \
--exec-prefix="${TOOLCHAIN_DIR}"/usr \
--sysconfdir="${TOOLCHAIN_DIR}"/etc \
--localstatedir="${TOOLCHAIN_DIR}"/var \
--program-prefix=\"" >> ${ENV_SETUP_FILE}
echo "alias configure=\"./configure \${CONFIGURE_FLAGS}\"" >> ${ENV_SETUP_FILE}
echo "export \"PATH="${TOOLCHAIN_DIR}/bin:\$PATH\" >> ${ENV_SETUP_FILE}
echo "export \"KERNELDIR="${LINUX_DIR}\" >> ${ENV_SETUP_FILE}

