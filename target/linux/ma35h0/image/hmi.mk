define Device/128m-nand
  $(Device/hmi-nand)
  DEVICE_MODEL := HMI
  DEVICE_VARIANT := 128M with NAND
  DEVICE_DTS := nuvoton/ma35h0-hmi-128m
  DEVICE_DTS_CONFIG := image-ma35h0-hmi-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-nand

define Device/128m-spinand
  $(Device/hmi-nand)
  DEVICE_MODEL := HMI
  DEVICE_VARIANT := 128M with SPINAND
  DEVICE_DTS := nuvoton/ma35h0-hmi-128m
  DEVICE_DTS_CONFIG := image-ma35h0-hmi-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-spinand

define Device/128m-sdcard0
  $(Device/hmi-sdcard)
  DEVICE_MODEL := HMI
  DEVICE_VARIANT := 128M with SDHC 0
  DEVICE_DTS := nuvoton/ma35h0-hmi-128m
  DEVICE_DTS_CONFIG := image-ma35h0-hmi-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-sdcard0

define Device/128m-sdcard1
  $(Device/hmi-sdcard)
  DEVICE_MODEL := HMI
  DEVICE_VARIANT := 128M with SDHC 1
  DEVICE_DTS := nuvoton/ma35h0-hmi-128m
  DEVICE_DTS_CONFIG := image-ma35h0-hmi-128m
  $(Device/select-dtb)
endef
TARGET_DEVICES += 128m-sdcard1
