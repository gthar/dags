.PHONY: all

VAULT_TLS=/srv/certs/vault/tls
ACME_DIR=/srv/certs/acme
DOMAIN=vault.monotremata.xyz

CERT_PATH=$(ACME_DIR)/$(DOMAIN)
CERT=$(CERT_PATH)/cert.pem
KEY=$(CERT_PATH)/key.pem

DEST_CERT=$(VAULT_TLS)/tls.crt
DEST_KEY=$(VAULT_TLS)/tls.key

all: $(DEST_CERT) $(DEST_KEY)

$(DEST_CERT): $(CERT)
	mkdir -p $(@D)
	install -o vault -g vault -m 600 $^ $@

$(DEST_KEY): $(KEY)
	mkdir -p $(@D)
	install -o vault -g vault -m 600 $^ $@
