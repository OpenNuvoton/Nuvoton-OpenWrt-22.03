define Device/128m-nand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M DDR with NAND
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-nand

define Device/256m-nand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M DDR with NAND
  DEVICE_DTS := nuvoton/ma35d1-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-nand

define Device/512m-nand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M DDR with NAND
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-nand

define Device/128m-spinand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M DDR with SPINAND
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-spinand

define Device/256m-spinand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M DDR with SPINAND
  DEVICE_DTS := nuvoton/ma35d1-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-spinand

define Device/512m-spinand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M DDR with SPINAND
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-spinand

define Device/128m-sdcard0
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M DDR with SDHC 0
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-sdcard0

define Device/256m-sdcard0
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M DDR with SDHC 0
  DEVICE_DTS := nuvoton/ma35d1-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-sdcard0

define Device/512m-sdcard0
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M DDR with SDHC 0
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-sdcard0

define Device/128m-sdcard1
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M DDR with SDHC 1
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-sdcard1

define Device/256m-sdcard1
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M DDR with SDHC 1
  DEVICE_DTS := nuvoton/ma35d1-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-sdcard1

define Device/512m-sdcard1
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M DDR with SDHC 1
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-sdcard1
