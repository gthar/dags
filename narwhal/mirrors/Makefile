include Make.config
include Make.init

################################################################################

all: alpine rpi_firmware tftp
.PHONY: all alpine force rpi_firwmare tftp

################################################################################

alpine: $(ALPINE_FOLDERS)

RSYNC_ARGS=--archive --update --hard-links --delete --delete-after --delay-updates --timeout=600 --progress

$(ALPINE_DEST)/%: force
	@mkdir -p $(@D)
	@echo $@
	@rsync $(RSYNC_ARGS) $(ALPINE_URL)/alpine/$* $(@D)

################################################################################

rpi_firmware:
	git -C $(RPI_FIRMWARE_DEST) pull

################################################################################

tftp:
	make -C tftp

################################################################################

# vi: ft=make
