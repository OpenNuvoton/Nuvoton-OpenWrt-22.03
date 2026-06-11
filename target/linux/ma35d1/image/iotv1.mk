define Device/512m-nand
  $(Device/iotv1-nand)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 512M DDR with NAND
  DEVICE_DTS := nuvoton/ma35d1-iot-ma35d16fj0-v1-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-ma35d16fj0-v1-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-nand

define Device/512m-spinand
  $(Device/iotv1-nand)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 512M DDR with SPINAND
  DEVICE_DTS := nuvoton/ma35d1-iot-ma35d16fj0-v1-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-ma35d16fj0-v1-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-spinand

define Device/512m-sdcard0
  $(Device/iotv1-sdcard)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 512M DDR with SDHC 0
  DEVICE_DTS := nuvoton/ma35d1-iot-ma35d16fj0-v1-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-ma35d16fj0-v1-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-sdcard0

define Device/512m-sdcard1
  $(Device/iotv1-sdcard)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 512M DDR with SDHC 1
  DEVICE_DTS := nuvoton/ma35d1-iot-ma35d16fj0-v1-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-ma35d16fj0-v1-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-sdcard1
