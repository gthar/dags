.PHONY: all

VAULT_TLS=/opt/vault/tls
ACME_DIR=/srv/certs/acme
DOMAIN=monotremata.xyz

CERT_PATH=$(ACME_DIR)/$(DOMAIN)
CERT=$(CERT_PATH)/$(DOMAIN).cer
KEY=$(CERT_PATH)/$(DOMAIN).key

VAULT_CERT=$(VAULT_TLS)/tls.crt
VAULT_KEY=$(VAULT_TLS)/tls.key

all: $(VAULT_CERT) $(VAULT_KEY)

$(VAULT_CERT): $(CERT)
	mkdir -p $(@D)
	install -m 600 $^ $@

$(VAULT_KEY): $(KEY)
	mkdir -p $(@D)
	install -m 600 $^ $@
