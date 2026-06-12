define Device/256m-nand
  $(Device/iotv1-nand)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 256M DDR with NAND
  DEVICE_DTS := nuvoton/ma35d0-iot-ma35d05ki1-v1-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-ma35d05ki1-v1-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-nand

define Device/256m-spinand
  $(Device/iotv1-nand)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 256M DDR with SPINAND
  DEVICE_DTS := nuvoton/ma35d0-iot-ma35d05ki1-v1-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-ma35d05ki1-v1-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-spinand

define Device/256m-sdcard0
  $(Device/iotv1-sdcard)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 256M DDR with SDHC 0
  DEVICE_DTS := nuvoton/ma35d0-iot-ma35d05ki1-v1-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-ma35d05ki1-v1-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-sdcard0

define Device/256m-sdcard1
  $(Device/iotv1-sdcard)
  DEVICE_MODEL := IoTv1
  DEVICE_VARIANT := 256M DDR with SDHC 1
  DEVICE_DTS := nuvoton/ma35d0-iot-ma35d05ki1-v1-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-ma35d05ki1-v1-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-sdcard1
