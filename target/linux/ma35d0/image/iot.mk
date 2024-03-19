define Device/256m-nand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M with NAND
  DEVICE_DTS := nuvoton/ma35d0-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-nand

define Device/256m-spinand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M with SPINAND
  DEVICE_DTS := nuvoton/ma35d0-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-spinand

define Device/256m-sdcard0
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M with SDHC 0
  DEVICE_DTS := nuvoton/ma35d0-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-sdcard0

define Device/256m-sdcard1
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 256M with SDHC 1
  DEVICE_DTS := nuvoton/ma35d0-iot-256m
  DEVICE_DTS_CONFIG := image-ma35d0-iot-256m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 256m-sdcard1
