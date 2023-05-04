include ../../Make.config
include ../Make.config
include Make.config

RPI=rpi

RPI_BOOT_PATH = $(RPI_FIRMWARE_DEST)/boot

ALPINE_FILES_PATH = alpine/$(ALPINE_VERSION)
NETBOOT_FILES_PATH = $(ALPINE_FILES_PATH)/releases/$(ARCH)/netboot-$(ALPINE_REVISION)

ALPINE_REPO = $(PXE_URL)/$(ALPINE_FILES_PATH)/main
MODLOOP = $(PXE_URL)/$(NETBOOT_FILES_PATH)/modloop-$(RPI)

DEST_DIR = $(TFTP_DIR)/$(SERIAL_NO)

all: $(DEST_DIR)/fixup.dat $(DEST_DIR)/start.elf $(DEST_DIR)/bcm2710-rpi-3-b-plus.dtb $(DEST_DIR)/initramfs-rpi $(DEST_DIR)/vmlinuz-rpi $(DEST_DIR)/config.txt $(DEST_DIR)/cmdline.txt

$(DEST_DIR)/fixup.dat: $(RPI_BOOT_PATH)/fixup.dat
	mkdir -p $(@D)
	install --mode=644 $< $@

$(DEST_DIR)/start.elf: $(RPI_BOOT_PATH)/start.elf
	mkdir -p $(@D)
	install --mode=644 $^ $@

$(DEST_DIR)/bcm2710-rpi-3-b-plus.dtb: $(RPI_BOOT_PATH)/bcm2710-rpi-3-b-plus.dtb
	mkdir -p $(@D)
	install --mode=644 $^ $@

$(DEST_DIR)/initramfs-rpi: $(MIRRORS_PATH)/$(NETBOOT_FILES_PATH)/initramfs-rpi
	mkdir -p $(@D)
	install --mode=644 $^ $@

$(DEST_DIR)/vmlinuz-rpi: $(MIRRORS_PATH)/$(NETBOOT_FILES_PATH)/vmlinuz-rpi
	mkdir -p $(@D)
	install --mode=644 $^ $@

$(DEST_DIR)/cmdline.txt:
	mkdir -p $(@D)
	echo "modules=loop,squashfs console=ttyAMA0,115200 ip=dhcp alpine_repo=$(ALPINE_REPO) modloop=$(MODLOOP)" > $@

$(DEST_DIR)/config.txt: config.txt
	mkdir -p $(@D)
	install --mode=644 $^ $@
