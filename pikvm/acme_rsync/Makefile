# because we are using pikvm here and making use of its persistent storage,
# remember to run it as `kvmd-pstrun make`
# https://docs.pikvm.org/pst/

ifdef KVMD_PST_DATA  # should be set to `/var/lib/kvmd/pst/data`
DATA_DIR := $(KVMD_PST_DATA)
else
DATA_DIR := /tmp
endif

WD=$(DATA_DIR)/dags/acme_rsync

.PHONY: all sync_certs

NGINX_RELOAD=$(WD)/nginx_reload

all: sync_certs $(NGINX_RELOAD)

###############################################################################

ACME_DIR=$(DATA_DIR)/acme
DOMAIN=monotremata.xyz
CERT_PATH=$(ACME_DIR)/$(DOMAIN)
CERT=$(CERT_PATH)/fullchain.cer
KEY=$(CERT_PATH)/$(DOMAIN).key

###############################################################################

$(CERT): sync_certs
$(KEY): sync_certs

###############################################################################
# Sync the certificates using rsync. Because `sync` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

$(CERT): sync_certs
$(KEY): sync_certs

RSYNCD_HOST=narwhal
RSYNCD_USER=user

GOPASS=doas -u gopass gopass
RSYNC_PASSWORD = $(shell $(GOPASS) $(RSYNCD_HOST)/rsyncd/$(RSYNCD_USER))

REMOTE_ACME_PATH=rsync://$(RSYNCD_USER)@10.0.0.5/acme
RSYNC_OPTS=--archive --delete --acls --xattrs --compress --verbose --human-readable

sync_certs:
	mkdir -p $(ACME_DIR)
	@echo "data dir: $(DATA_DIR)"
	@echo "running rsync"
	@export RSYNC_PASSWORD=$(RSYNC_PASSWORD); \
	rsync \
		$(RSYNC_OPTS) \
		$(REMOTE_ACME_PATH) \
		$(ACME_DIR)

###############################################################################

$(NGINX_RELOAD): $(CERT) $(KEY)
	@echo "reloading nginx"
	mkdir -p $(@D)
	systemctl reload kvmd-nginx
	touch $@

###############################################################################
