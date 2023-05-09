# because we are using pikvm here and making use of its persistent storage,
# remember to run it as `kvmd-pstrun make`
# https://docs.pikvm.org/pst/

ifdef KVMD_PST_DATA  # should be set to `/var/lib/kvmd/pst/data`
DATA_DIR := $(KVMD_PST_DATA)
else
DATA_DIR := /tmp
endif

WD=$(DATA_DIR)/dags/acme_refresh

.PHONY: all

NGINX_RELOAD=$(WD)/nginx_reload

all: $(NGINX_RELOAD)

###############################################################################

ACME_DIR=$(DATA_DIR)/acme
DOMAIN=monotremata.xyz
CERT_PATH=$(ACME_DIR)/$(DOMAIN)
CERT=$(CERT_PATH)/fullchain.cer
KEY=$(CERT_PATH)/$(DOMAIN).key

###############################################################################

$(NGINX_RELOAD): $(CERT) $(KEY)
	@echo "reloading nginx"
	mkdir -p $(@D)
	systemctl reload kvmd-nginx
	touch $@

###############################################################################
