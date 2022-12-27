define Device/128m-nand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M with NAND
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-nand

define Device/512m-nand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M with NAND
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-nand

define Device/128m-spinand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M with SPINAND
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-spinand

define Device/512m-spinand
  $(Device/iot-nand)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M with SPINAND
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-spinand

define Device/128m-sdcard
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 128M with SDCARD
  DEVICE_DTS := nuvoton/ma35d1-iot-128m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-sdcard

define Device/512m-sdcard
  $(Device/iot-sdcard)
  DEVICE_MODEL := IoT
  DEVICE_VARIANT := 512M with SDCARD
  DEVICE_DTS := nuvoton/ma35d1-iot-512m
  DEVICE_DTS_CONFIG := image-ma35d1-iot-512m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 512m-sdcard
