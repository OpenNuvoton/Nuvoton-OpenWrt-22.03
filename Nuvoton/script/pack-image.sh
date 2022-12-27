#!/usr/bin/env bash

ROOT_DIR=${KDIR}/../../..
HOST_DIR=${STAGING_DIR_IMAGE}/../../host
NUWRITER_DIR=${ROOT_DIR}/Nuvoton/nuwriter
CONFIG_FILE=${ROOT_DIR}/.config

IMAGE_BASENAME="openwrt-ma35d1"
UBINIZE_ARGS="-m 2048 -p 128KiB -s 2048 -O 2048"

optee_image()
{
	if grep -Eq "^CONFIG_PACKAGE_optee-generic=y$" ${CONFIG_FILE}; then
		echo "yes"
	else
		echo "no"
	fi
}

IMAGE_CMD-spinand() {
	( \
		cd ${STAGING_DIR_IMAGE}; \
		cp ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.bin-spinand; \
		cp ${STAGING_DIR_IMAGE}/uboot-env.txt ${STAGING_DIR_IMAGE}/uboot-env.txt-spinand; \
		${HOST_DIR}/bin/ubinize ${UBINIZE_ARGS} -o ${STAGING_DIR_IMAGE}/uboot-env.ubi-spinand ${STAGING_DIR_IMAGE}/ma35d1-uEnv-spinand-ubi.cfg; \
	)

	if [ -f ${STAGING_DIR_IMAGE}/fip.bin ]; then
		( \
			cd ${STAGING_DIR_IMAGE}; \
			ln -sf ${BIN_DIR}/openwrt-${BOARD}-${SUBTARGET}-${DEVICE_NAME}-squashfs-firmware.bin firmware.bin; \
			cp fip.bin fip.bin-spinand; \
			python3 ${NUWRITER_DIR}/nuwriter.py -c ${NUWRITER_DIR}/header-spinand.json; \
			cp conv/header.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header.bin; \
			python3 ${NUWRITER_DIR}/nuwriter.py -p ${NUWRITER_DIR}/pack-spinand.json; \
			cp pack/pack.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack.bin; \
			rm -rf $(date "+%m%d-*") conv pack; \
		)
	fi
}

IMAGE_CMD-nand() {
	( \
		cd ${STAGING_DIR_IMAGE}; \
		cp ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.bin-nand; \
		cp ${STAGING_DIR_IMAGE}/uboot-env.txt ${STAGING_DIR_IMAGE}/uboot-env.txt-nand; \
		${HOST_DIR}/bin/ubinize ${UBINIZE_ARGS} -o ${STAGING_DIR_IMAGE}/uboot-env.ubi-nand ${STAGING_DIR_IMAGE}/ma35d1-uEnv-nand-ubi.cfg; \
	)

	if [ -f ${STAGING_DIR_IMAGE}/fip.bin ]; then
		( \
			cd ${STAGING_DIR_IMAGE}; \
			ln -sf ${BIN_DIR}/openwrt-${BOARD}-${SUBTARGET}-${DEVICE_NAME}-squashfs-firmware.bin firmware.bin; \
			cp fip.bin fip.bin-nand; \
			python3 ${NUWRITER_DIR}/nuwriter.py -c ${NUWRITER_DIR}/header-nand.json; \
			cp conv/header.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header.bin; \
			python3 ${NUWRITER_DIR}/nuwriter.py -p ${NUWRITER_DIR}/pack-nand.json; \
			cp pack/pack.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack.bin; \
			rm -rf $(date "+%m%d-*") conv pack; \
		)
	fi
}

IMAGE_CMD_sdcard() {
	SDCARD_IMG=${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}_dd.img;
	EXT4_START=$((3072+1024+${CONFIG_TARGET_KERNEL_PARTSIZE}*1024))
	EXT4_END=$(($EXT4_START+${CONFIG_TARGET_ROOTFS_PARTSIZE}*1024))

	dd if=${KDIR}/${DEVICE_NAME}.pt of=${STAGING_DIR_IMAGE}/MBR.scdard.bin conv=notrunc,fsync seek=0 count=1 bs=512

	( \
		cd ${STAGING_DIR_IMAGE}; \
		cp ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.bin-sdcard; \
		cp ${STAGING_DIR_IMAGE}/uboot-env.txt ${STAGING_DIR_IMAGE}/uboot-env.txt-sdcard; \
		ln -sf ${KDIR}/root.ext4 rootfs.ext4; \
	)

	# for NuWriter flashing
	( \
		cd ${STAGING_DIR_IMAGE}; \
		ln -sf ${BIN_DIR}/openwrt-${BOARD}-${SUBTARGET}-${DEVICE_NAME}-uImage Image; \
		cp fip.bin fip.bin-sdcard; \
		python3 ${NUWRITER_DIR}/nuwriter.py -c ${NUWRITER_DIR}/header-sdcard.json; \
		cp conv/header.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-header.bin; \
		$(cat ${NUWRITER_DIR}/pack-sdcard.json | jq 'setpath(["image",8,"offset"];"'$((${EXT4_START}*1024))'")' > ${STAGING_DIR_IMAGE}/pack-sdcard.json); \
		python3 ${NUWRITER_DIR}/nuwriter.py -p ${STAGING_DIR_IMAGE}/pack-sdcard.json; \
		cp pack/pack.bin ${BIN_DIR}/${IMAGE_BASENAME}-${SUBTARGET}-${DEVICE_NAME}-pack.bin; \
		rm -rf $(date "+%m%d-*") conv pack; \
	)
}

uboot_cmd() {
	cp ${ROOT_DIR}/Nuvoton/uboot_env/ma35d1-uboot-env.txt ${STAGING_DIR_IMAGE}/uboot-env.txt
	cp ${ROOT_DIR}/Nuvoton/uboot_env/*.cfg ${STAGING_DIR_IMAGE}/
	if echo $DEVICE_NAME | grep -q "256m"
	then
		if [[ $IS_OPTEE == "yes" ]]
		then
			sed -i "s/kernelmem=256M/kernelmem=248M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi

	elif echo $DEVICE_NAME | grep -q "128m"
	then
		sed -i "s/kernelmem=256M/kernelmem=128M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		if [[ $IS_OPTEE == "yes" ]]
		then
			sed -i "s/kernelmem=128M/kernelmem=120M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi
	elif echo $DEVICE_NAME | grep -q "512m"
	then
		sed -i "s/kernelmem=256M/kernelmem=512M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		if [[ $IS_OPTEE == "yes" ]]
		then
			sed -i "s/kernelmem=512M/kernelmem=504M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi
	elif echo $DEVICE_NAME | grep -q "1g"
	then
		sed -i "s/kernelmem=256M/kernelmem=1024M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		if [[ $IS_OPTEE == "yes" ]]
		then
			sed -i "s/kernelmem=1024M/kernelmem=1016M/1" ${STAGING_DIR_IMAGE}/uboot-env.txt
		fi
	fi

	if echo $DEVICE_NAME | grep -q "spinand"
	then
		sed -i "s/boot_targets=/boot_targets=mtd0 /1" ${STAGING_DIR_IMAGE}/uboot-env.txt
	elif echo $DEVICE_NAME | grep -q "nand"
	then
		sed -i "s/boot_targets=/boot_targets=nand0 /1" ${STAGING_DIR_IMAGE}/uboot-env.txt
	fi

	${HOST_DIR}/bin/mkenvimage -s 0x10000 -o ${STAGING_DIR_IMAGE}/uboot-env.bin ${STAGING_DIR_IMAGE}/uboot-env.txt
}

main()
{
	IS_OPTEE=$(optee_image)
	uboot_cmd
	if echo $DEVICE_NAME | grep -q "spinand"
	then
		IMAGE_CMD-spinand
	elif echo $DEVICE_NAME | grep -q "nand"
	then
		IMAGE_CMD-nand
	else
		IMAGE_CMD_sdcard
	fi

	echo "========================================================="
	echo "SUBTARGET = ${SUBTARGET}"
	echo "DEVICE_NAME = ${DEVICE_NAME}"
	echo "ROOT_DIR = ${ROOT_DIR}"
	echo "BIN_DIR = ${BIN_DIR}"
	echo "HOST_DIR = ${HOST_DIR}"
	echo "STAGING_DIR_IMAGE = ${STAGING_DIR_IMAGE}"

	exit $?
}

main $@
