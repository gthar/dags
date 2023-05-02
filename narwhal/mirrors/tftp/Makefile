include ../Make.config
include Make.config

all: $(TFTP_DIR)/bootcode.bin kitchen

.PHONY: kitchen

$(TFTP_DIR)/bootcode.bin: $(RPI_FIRMWARE_DEST)/boot/bootcode.bin
	install --mode=644 $< $@

kitchen:
	make -C kitchen
