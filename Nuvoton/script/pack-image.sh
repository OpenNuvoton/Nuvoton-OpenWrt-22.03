#!/usr/bin/env bash

CONFIG_FILE=${TOPDIR}/.config
NUWRITER_DIR=${TOPDIR}/Nuvoton/nuwriter

IMAGE_BASENAME="openwrt-ma35d1"
UBINIZE_ARGS="-m 2048 -p 128KiB -s 2048 -O 2048"

is_optee_image()
{
	if grep -Eq "^CONFIG_PACKAGE_optee-ma35d1=y$" ${CONFIG_FILE}; then
		echo "yes"
	else
		echo "no"
	fi
}

is_secure_boot()
{
	if grep -Eq "^CONFIG_MA35D1_SECURE_BOOT=y$" ${CONFIG_FILE}; then
		echo "yes"
	else
		echo "no"
	fi
}

uboot_cmd() {
	cp ${TOPDIR}/Nuvoton/uboot_env/ma35d1-uboot-env.txt ${STAGING_DIR_IMAGE}/uboot-env.txt
	cp ${TOPDIR}/Nuvoton/uboot_env/*.cfg ${STAGING_DIR_IMAGE}/
	if echo $DEVICE_NAME | grep -q "256m"; then
		if [ $IS_OPTEE == "yes" ]
		then
			sed -i "s/kernelmem=256M/kernelmem=248M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi

	elif echo $DEVICE_NAME | grep -q "128m"; then
		sed -i "s/kernelmem=256M/kernelmem=128M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		if [ $IS_OPTEE == "yes" ]
		then
			sed -i "s/kernelmem=128M/kernelmem=120M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi
	elif echo $DEVICE_NAME | grep -q "512m"; then
		sed -i "s/kernelmem=256M/kernelmem=512M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		if [ $IS_OPTEE == "yes" ]
		then
			sed -i "s/kernelmem=512M/kernelmem=504M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi
	elif echo $DEVICE_NAME | grep -q "1g"; then
		sed -i "s/kernelmem=256M/kernelmem=1024M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		if [ $IS_OPTEE == "yes" ]
		then
			sed -i "s/kernelmem=1024M/kernelmem=1016M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi
	fi

	if echo $DEVICE_NAME | grep -q "spinand"; then
		sed -i "s/boot_targets=/boot_targets=mtd0 /1" ${STAGING_DIR_IMAGE}/uboot-env.txt
	elif echo $DEVICE_NAME | grep -q "nand"; then
		sed -i "s/boot_targets=/boot_targets=nand0 /1" ${STAGING_DIR_IMAGE}/uboot-env.txt
	elif echo $DEVICE_NAME | grep -q "sdcard1" && [ "${SUBTARGET}" = "som" ]; then
		sed -i "s/mmc_block=mmcblk0p3/mmc_block=mmcblk1p3/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		sed -i "s/boot_targets=/boot_targets=mmc1 /1" ${STAGING_DIR_IMAGE}/uboot-env.txt
	fi

	${STAGING_DIR_HOST}/bin/mkenvimage -s 0x10000 -o ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.txt
}

build_fip() {
	if [ $IS_SECURE == "yes" ]; then
		cd ${STAGING_DIR_IMAGE}
		if [ ! -d ${STAGING_DIR_IMAGE}/fip ]; then
			mkdir ${STAGING_DIR_IMAGE}/fip
		fi

		cat ${TOPDIR}/Nuvoton/nuwriter/en_fip.json | \
			jq -r ".header.aeskey = \"${CONFIG_MA35D1_AES_KEY}\"" | \
			jq -r ".header.ecdsakey = \"${CONFIG_MA35D1_ECDSA_KEY}\"" \
			> ${STAGING_DIR_IMAGE}/fip/enc_fip.json

		for x in bl31.bin tee-header_v2.bin tee-pager_v2.bin u-boot.bin
		do
			cp ${STAGING_DIR_IMAGE}/$x ${STAGING_DIR_IMAGE}/fip/enc.bin
			python3 ${NUWRITER_DIR}/nuwriter.py -c ${STAGING_DIR_IMAGE}/fip/enc_fip.json > /dev/null
			cat conv/enc_enc.bin conv/header.bin > ${STAGING_DIR_IMAGE}/fip/enc_$x
			rm -rf `date "+%m%d-*"` conv pack
		done

		${STAGING_DIR_IMAGE}/fiptool create \
			--soc-fw ${STAGING_DIR_IMAGE}/fip/enc_bl31.bin \
			--tos-fw ${STAGING_DIR_IMAGE}/fip/enc_tee-header_v2.bin \
			--tos-fw-extra1 ${STAGING_DIR_IMAGE}/fip/enc_tee-pager_v2.bin \
			--nt-fw ${STAGING_DIR_IMAGE}/fip/enc_u-boot.bin \
			${STAGING_DIR_IMAGE}/fip.bin
	else
		${STAGING_DIR_IMAGE}/fiptool create \
			--soc-fw ${STAGING_DIR_IMAGE}/bl31.bin \
			--tos-fw ${STAGING_DIR_IMAGE}/tee-header_v2.bin \
			--tos-fw-extra1 ${STAGING_DIR_IMAGE}/tee-pager_v2.bin \
			--nt-fw ${STAGING_DIR_IMAGE}/u-boot.bin \
			${STAGING_DIR_IMAGE}/fip.bin
	fi
}

IMAGE_CMD_init() {
	# clear old images
	if [ -f ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header*.bin ]; then
		rm ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header*.bin
	fi
	if [ -f ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack*.bin ]; then
		rm ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack*.bin
	fi
	if [ -f ${BIN_DIR}/${IMAGE_BASENAME}-otp-key-enc.json ]; then
		rm ${BIN_DIR}/${IMAGE_BASENAME}-otp-key-enc.json
	fi

	# rename the sysupgrade image
	if [ $IS_SECURE == "yes" ]; then
		if [ $1 == "sdcard" ]; then
			if [ -f ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-ext4-sysupgrade.gz ]; then
				mv ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-ext4-sysupgrade.gz \
				   ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-ext4-sysupgrade-enc.gz
			fi
		else
			if [ -f ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-squashfs-sysupgrade.bin ]; then
				mv ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-squashfs-sysupgrade.bin \
				   ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-squashfs-sysupgrade-enc.bin
			fi
		fi
	fi
}

IMAGE_CMD_header() {
	cd ${STAGING_DIR_IMAGE}
	if [ $IS_SECURE == "yes" ]; then
		cat ${NUWRITER_DIR}/header-$1.json | \
			jq -r ".header.secureboot = \"yes\"" | \
			jq -r ".header.aeskey = \"${CONFIG_MA35D1_AES_KEY}\"" | \
			jq -r ".header.ecdsakey = \"${CONFIG_MA35D1_ECDSA_KEY}\"" \
			> ${STAGING_DIR_IMAGE}/header-$1.json
		python3 ${NUWRITER_DIR}/nuwriter.py -c ${STAGING_DIR_IMAGE}/header-$1.json
		cp conv/header.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header-enc.bin
		ln -sf ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header-enc.bin header.bin
		cp conv/enc_bl2.dtb enc_bl2.dtb
		cp conv/enc_bl2.bin enc_bl2.bin
		echo "{\""publicx"\": \""$(sed -n 6p conv/header_key.txt)"\", \
			\""publicy"\": \""$(sed -n 7p conv/header_key.txt)"\", \
			\""aeskey"\": \""$(sed -n 2p conv/header_key.txt)"\"}" | \
			jq  > ${BIN_DIR}/${IMAGE_BASENAME}-otp-key-enc.json
		rm -rf `date "+%m%d-*"` conv pack

	else
		python3 ${NUWRITER_DIR}/nuwriter.py -c ${NUWRITER_DIR}/header-$1.json
		cp conv/header.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header.bin
		ln -sf ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header.bin header.bin
		rm -rf `date "+%m%d-*"` conv pack
	fi
}

IMAGE_CMD_pack() {
	cp ${STAGING_DIR_IMAGE}/fip.bin ${STAGING_DIR_IMAGE}/fip.bin-$1

	if [ $IS_SECURE == "yes" ]; then
		if [ $1 == "sdcard" ]; then
			cat ${STAGING_DIR_IMAGE}/pack-$1.json | \
				jq 'setpath(["image",2,"file"];"enc_bl2.dtb")' | \
				jq 'setpath(["image",3,"file"];"enc_bl2.bin")' \
				> ${STAGING_DIR_IMAGE}/pack-$1-enc.json
		else
			cat ${STAGING_DIR_IMAGE}/pack-$1.json | \
				jq 'setpath(["image",1,"file"];"enc_bl2.dtb")' | \
				jq 'setpath(["image",2,"file"];"enc_bl2.bin")' \
				> ${STAGING_DIR_IMAGE}/pack-$1-enc.json
		fi
		python3 ${NUWRITER_DIR}/nuwriter.py -p ${STAGING_DIR_IMAGE}/pack-$1-enc.json
		cp pack/pack.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack-enc.bin
		rm -rf `date "+%m%d-*"` conv pack
	else
		python3 ${NUWRITER_DIR}/nuwriter.py -p ${STAGING_DIR_IMAGE}/pack-$1.json
		cp pack/pack.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack.bin
		rm -rf `date "+%m%d-*"` conv pack
	fi
}

IMAGE_CMD-spinand() {
	cd ${STAGING_DIR_IMAGE}
	cp ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.bin-spinand
	# convert image to UBI format for SPINAND
	${STAGING_DIR_HOST}/bin/ubinize ${UBINIZE_ARGS} -o ${STAGING_DIR_IMAGE}/uboot-env.ubi-spinand ${STAGING_DIR_IMAGE}/ma35d1-uEnv-spinand-ubi.cfg

	ln -sf ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-squashfs-firmware.bin firmware.bin
	cp ${NUWRITER_DIR}/pack-spinand.json ${STAGING_DIR_IMAGE}/pack-spinand.json

	IMAGE_CMD_init spinand
	IMAGE_CMD_header spinand
	IMAGE_CMD_pack spinand
}

IMAGE_CMD-nand() {
	cd ${STAGING_DIR_IMAGE}
	cp ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.bin-nand

	ln -sf ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-squashfs-firmware.bin firmware.bin
	cp ${NUWRITER_DIR}/pack-nand.json ${STAGING_DIR_IMAGE}/pack-nand.json

	IMAGE_CMD_init nand
	IMAGE_CMD_header nand
	IMAGE_CMD_pack nand
}

IMAGE_CMD_sdcard() {
	EXT4_START=$((3072+1024+${CONFIG_TARGET_KERNEL_PARTSIZE}*1024))
	EXT4_END=$(($EXT4_START+${CONFIG_TARGET_ROOTFS_PARTSIZE}*1024))

	cd ${STAGING_DIR_IMAGE}
	cp ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.bin-sdcard

	dd if=${KDIR}/${DEVICE_NAME}.pt of=${STAGING_DIR_IMAGE}/MBR.sdcard.bin conv=notrunc,fsync seek=0 count=1 bs=512
	ln -sf ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-uImage Image
	ln -sf ${KDIR}/root.ext4 rootfs.ext4

	IMAGE_CMD_init sdcard
	IMAGE_CMD_header sdcard
	cat ${NUWRITER_DIR}/pack-sdcard.json | \
		jq 'setpath(["image",8,"offset"];"'$((${EXT4_START}*1024))'")' \
		> ${STAGING_DIR_IMAGE}/pack-sdcard.json
	IMAGE_CMD_pack sdcard
}

main()
{
	IS_OPTEE=$(is_optee_image)
	IS_SECURE=$(is_secure_boot)

	uboot_cmd
	build_fip

	if echo $DEVICE_NAME | grep -q "spinand"; then
		IMAGE_CMD-spinand
	elif echo $DEVICE_NAME | grep -q "nand"; then
		IMAGE_CMD-nand
	else
		IMAGE_CMD_sdcard
	fi

	echo "========================================================="
	echo "DEVICE_NAME = ${DEVICE_NAME}"
	echo "BOARD = ${BOARD}"
	echo "SUBTARGET = ${SUBTARGET}"
	echo "PROFILE = ${PROFILE}"

	exit $?
}

main $@
