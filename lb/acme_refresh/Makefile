WD=/var/lib/dags/acme_refresh

###############################################################################

ACME_DIR=/srv/certs/acme
DOMAIN=monotremata.xyz
CERT_PATH=$(ACME_DIR)/$(DOMAIN)
FULLCHAIN=$(CERT_PATH)/fullchain.cer
CERT=$(CERT_PATH)/$(DOMAIN).cer
KEY=$(CERT_PATH)/$(DOMAIN).key

APKOVL=/media/mmcblk0p2/lb.apkovl.tar.gz

NGINX_RELOAD=$(WD)/nginx_reload

###############################################################################

.PHONY: all

all: $(NGINX_RELOAD) $(APKOVL)

###############################################################################

$(NGINX_RELOAD): $(FULLCHAIN) $(CERT) $(KEY)
	mkdir -p $(@)
	nginx -s reload
	touch $@

$(APKOVL): $(FULLCHAIN) $(CERT) $(KEY)
	lbu add $(CERT_PATH)
	lbu commit

###############################################################################
