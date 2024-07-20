KERNEL_LOADADDR := 0x48080000

define Build/mt798x-gpt
	cp $@ $@.tmp 2>/dev/null || true
	ptgen -g -o $@.tmp -a 1 -l 1024 \
			-H \
			-t 0x83	-N bl2		-r	-p 3584K@512k \
			-t 0x83	-N u-boot-env	-r 	-p 512k@4M \
			-t 0x83	-N factory	-r	-p 4M@4608K \
			-t 0xef	-N fip		-r	-p 2M@8704k \
					-N kernel	-r	-p 32M@10752K \
			-t 0x2e 	-N rootfs		-p $(CONFIG_TARGET_ROOTFS_PARTSIZE)M@43520K 
	cat $@.tmp >> $@.gpt
	rm $@.tmp
endef

define Build/make_bpi-r4_bundle_image_sd
	./make_bpi-r4_bundle_image.sh  $@ \
		$@.gpt \
		./bl2_sd.img \
		./fip_sd.bin \
		$(IMAGE_KERNEL) \
		$(IMAGE_ROOTFS)
endef

define Build/make_bpi-r4_bundle_image_emmc
	./make_bpi-r4_bundle_image.sh  $@ \
		$@.gpt \
		./bl2_emmc.img \
		./fip_emmc.bin \
		$(IMAGE_KERNEL)  \
		$(IMAGE_ROOTFS)
endef

define Build/make_bpi-r4_bundle_nandimage
	./make_bpi-r4_bundle_nandimage.sh  $@ \
		./bl2_nand.img \
		./fip_nand.bin \
		$(KDIR)/tmp/openwrt-mediatek-mt7988-BPI-R4-NAND-squashfs-factory.bin
endef

define Device/BPI-R4-SD
  DEVICE_VENDOR := Banana Pi
  DEVICE_MODEL := Banana Pi R4
  DEVICE_TITLE := MTK7988a BPI R4 SD
  DEVICE_DTS := mt7988a-bananapi-bpi-r4-sd
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek
  SUPPORTED_DEVICES := bananapi,bpi-r4
  DEVICE_PACKAGES := mkf2fs e2fsprogs blkid blockdev losetup kmod-fs-ext4 \
		     kmod-mmc kmod-fs-f2fs kmod-fs-vfat kmod-nls-cp437 \
		     kmod-nls-iso8859-1
  IMAGES += single.img.gz 		     
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  IMAGE/single.img.gz := mt798x-gpt | make_bpi-r4_bundle_image_sd | gzip | append-metadata 
endef
TARGET_DEVICES += BPI-R4-SD

define Device/BPI-R4-EMMC
  DEVICE_VENDOR := Banana Pi
  DEVICE_MODEL := Banana Pi R4
  DEVICE_TITLE := MTK7988a BPI R4 EMMC
  DEVICE_DTS := mt7988a-bananapi-bpi-r4-emmc
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek
  SUPPORTED_DEVICES := bananapi,bpi-r4
  DEVICE_PACKAGES := mkf2fs e2fsprogs blkid blockdev losetup kmod-fs-ext4 \
		     kmod-mmc kmod-fs-f2fs kmod-fs-vfat kmod-nls-cp437 \
		     kmod-nls-iso8859-1
  IMAGES += single.img.gz 		     
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  IMAGE/single.img.gz := mt798x-gpt | make_bpi-r4_bundle_image_emmc | gzip | append-metadata
endef
TARGET_DEVICES += BPI-R4-EMMC

define Device/BPI-R4-NAND
  DEVICE_VENDOR := Banana Pi
  DEVICE_MODEL := Banana Pi R4
  DEVICE_TITLE := MTK7988a BPI R4 NAND
  DEVICE_DTS := mt7988a-bananapi-bpi-r4-nand
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek
  SUPPORTED_DEVICES := bananapi,bpi-r4-nand
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  IMAGE_SIZE := 131072k
  KERNEL_IN_UBI := 1
  IMAGES += factory.bin
  IMAGE/factory.bin := append-ubi | check-size $$$$(IMAGE_SIZE)
  IMAGE/single.img.gz :=  $$(IMAGE/factory.bin) | make_bpi-r4_bundle_nandimage | gzip | append-metadata  
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += BPI-R4-NAND
