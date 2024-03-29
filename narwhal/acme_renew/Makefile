WD=/var/lib/dags/acme_renew

.PHONY: all refresh_pg renew_certs lb_sync

NGINX_RELOAD=$(WD)/nginx_reload

CALADAN_SYNC=$(WD)/caladan_sync
FUGU_SYNC=$(WD)/fugu_sync
LB_SYNC=$(WD)/lb_sync
SURICATA_SYNC=$(WD)/suricata_sync

CALADAN_TRIGGER=$(WD)/caladan_trigger
FUGU_TRIGGER=$(WD)/fugu_trigger
LB_TRIGGER=$(WD)/lb_trigger
SURICATA_TRIGGER=$(WD)/suricata_trigger

all: renew_certs $(CALADAN_TRIGGER) $(FUGU_TRIGGER) $(LB_TRIGGER) $(SURICATA_TRIGGER) $(NGINX_RELOAD) refresh_pg refresh_vault

###############################################################################

ACME_DIR=/srv/certs/acme
DOMAIN=monotremata.xyz

CERT_PATH=$(ACME_DIR)/$(DOMAIN)
FULLCHAIN=$(CERT_PATH)/fullchain.pem
CERT=$(CERT_PATH)/cert.pem
KEY=$(CERT_PATH)/key.pem

MAIL_CERT_PATH=$(ACME_DIR)/mail.$(DOMAIN)
MAIL_FULLCHAIN=$(MAIL_CERT_PATH)/fullchain.pem
MAIL_CERT=$(MAIL_CERT_PATH)/cert.pem
MAIL_KEY=$(MAIL_CERT_PATH)/key.pem

CUINA_CERT_PATH=$(ACME_DIR)/cuina.$(DOMAIN)
CUINA_FULLCHAIN=$(CUINA_CERT_PATH)/fullchain.pem
CUINA_CERT=$(CUINA_CERT_PATH)/cert.pem
CUINA_KEY=$(CUINA_CERT_PATH)/key.pem

VAULT_CERT_PATH=$(ACME_DIR)/vault.$(DOMAIN)
VAULT_FULLCHAIN=$(VAULT_CERT_PATH)/fullchain.pem
VAULT_CERT=$(VAULT_CERT_PATH)/cert.pem
VAULT_KEY=$(VAULT_CERT_PATH)/key.pem

###############################################################################

SSH_KEY=/srv/certs/ssh/users/dags/id_ed25519

###############################################################################
# Renew the certificates using acme.sh. Because `renew_certs` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

CERT_DOMAINS=-d $(DOMAIN) -d '*.$(DOMAIN)' -d '*.narwhal.$(DOMAIN)' -d '*.caladan.$(DOMAIN)' -d '*.xmpp.$(DOMAIN)'

$(FULLCHAIN): renew_certs
$(CERT): renew_certs
$(KEY): renew_certs

HETZNER_TOKEN=/srv/secrets/hetzner_token

DOCKER_IMAGE=neilpang/acme.sh
ACME_DATA_DIR=/mnt/docker_volumes/acmesh/data

ACMESH=docker run --rm -it \
	-v $(ACME_DATA_DIR):/acme.sh \
	-v $(CERT_PATH):/acme.sh/$(DOMAIN) \
	-e "HETZNER_Token=$$(cat $(HETZNER_TOKEN))" \
	$(DOCKER_IMAGE) \
	/root/.acme.sh/acme.sh 


RENEW_CMD=--cron --home /root/.acme.sh --config-home /acme.sh

# DNS_ARGS=--dns dns_linode_v4 --dnssleep 900
DNS_ARGS=--dns dns_hetzner

renew_certs: $(HETZNER_TOKEN)
	@echo "renewing certs"
	$(ACMESH) $(RENEW_CMD)

###############################################################################
# Sync the certs to remote hosts and trigger DAGs there

RSYNC_ARGS=--archive --delete --compress --verbose --human-readable --rsh "ssh -i $(SSH_KEY)"

$(CALADAN_SYNC): $(FULLCHAIN) $(CERT) $(KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$^ \
		dags@caladan:$(CERT_PATH)
	touch $@

$(FUGU_SYNC): $(MAIL_FULLCHAIN) $(MAIL_CERT) $(MAIL_KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$^ \
		dags@fugu:$(MAIL_CERT_PATH)
	touch $@

$(SURICATA_SYNC): $(VAULT_FULLCHAIN) $(VAULT_CERT) $(VAULT_KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$^ \
		dags@suricata:$(VAULT_CERT_PATH)
	touch $@


$(LB_SYNC): $(FULLCHAIN) $(CERT) $(KEY) $(CUINA_FULLCHAIN) $(CUINA_CERT) $(CUINA_KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$(FULLCHAIN) $(CERT) $(KEY) \
		dags@lb:/etc/nginx/acme/$(DOMAIN)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$(CUINA_FULLCHAIN) $(CUINA_CERT) $(CUINA_KEY) \
		dags@lb:/etc/nginx/acme/cuina.$(DOMAIN)
	touch $@

KVMD_PST_DATA=/var/lib/kvmd/pst/data

define remote_dag_trigger
	mkdir -p $(@D)
	ssh -i $(SSH_KEY) dags@$(1) "doas /srv/dags/$(1)/$(2)/run.sh"
	touch $@
endef

$(CALADAN_TRIGGER): $(CALADAN_SYNC)
	$(call remote_dag_trigger,caladan,acme_refresh)

$(FUGU_TRIGGER): $(FUGU_SYNC)
	$(call remote_dag_trigger,fugu,acme_refresh)

$(LB_TRIGGER): $(LB_SYNC)
	$(call remote_dag_trigger,lb,acme_refresh)

$(SURICATA_TRIGGER): $(SURICATA_SYNC)
	$(call remote_dag_trigger,suricata,acme_refresh)

###############################################################################
# Copy the certificate for the postgresql domain to the folder where postgre
# service expects it

PG_SSL_PATH=/mnt/docker_volumes/postgres/ssl
PG_CERT=$(PG_SSL_PATH)/server.crt
PG_KEY=$(PG_SSL_PATH)/server.key

$(PG_CERT): $(FULLCHAIN)
	mkdir -p $(@D)
	rsync --copy-links $< $@

$(PG_KEY): $(KEY)
	mkdir -p $(@D)
	rsync --copy-links $< $@

refresh_pg: $(PG_CERT) $(PG_KEY)

###############################################################################
# Copy Vault certificate

VAULT_DEST_PATH=/srv/certs/vault/tls
VAULT_DEST_CERT=$(VAULT_DEST_PATH)/tls.crt
VAULT_DEST_KEY=$(VAULT_DEST_PATH)/tls.key

$(VAULT_DEST_CERT): $(VAULT_CERT)
	mkdir -p $(@D)
	install -o vault -g vault -m 600 $^ $@

$(VAULT_DEST_KEY): $(VAULT_KEY)
	mkdir -p $(@D)
	install -o vault -g vault -m 600 $^ $@

refresh_vault: $(VAULT_DEST_CERT) $(VAULT_DEST_KEY)
