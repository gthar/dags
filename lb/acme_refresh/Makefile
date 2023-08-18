WD=/var/lib/dags/acme_refresh

###############################################################################

ACME_DIR=/etc/nginx/acme

DOMAIN=monotremata.xyz

CERT_PATH=$(ACME_DIR)/$(DOMAIN)
FULLCHAIN=$(CERT_PATH)/fullchain.pem
CERT=$(CERT_PATH)/cert.pem
KEY=$(CERT_PATH)/key.pem

CUINA_CERT_PATH=$(ACME_DIR)/cuina.$(DOMAIN)
CUINA_FULLCHAIN=$(CUINA_CERT_PATH)/fullchain.pem
CUINA_CERT=$(CUINA_CERT_PATH)/cert.pem
CUINA_KEY=$(CUINA_CERT_PATH)/key.pem

APKOVL=/media/mmcblk0p2/lb.apkovl.tar.gz

NGINX_RELOAD=$(WD)/nginx_reload

###############################################################################

.PHONY: all

all: $(NGINX_RELOAD) $(APKOVL)

###############################################################################

$(NGINX_RELOAD): $(FULLCHAIN) $(CERT) $(KEY) $(CUINA_FULLCHAIN) $(CUINA_CERT) $(CUINA_KEY)
	mkdir -p $(@)
	nginx -s reload
	touch $@

$(APKOVL): $(FULLCHAIN) $(CERT) $(KEY) $(CUINA_FULLCHAIN) $(CUINA_CERT) $(CUINA_KEY)
	lbu add $(CERT_PATH) $(CUINA_CERT_PATH)
	lbu commit

###############################################################################
