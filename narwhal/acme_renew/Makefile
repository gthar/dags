WD=/var/lib/dags/acme_renew

.PHONY: all refresh_pg renew_certs

NGINX_RELOAD=$(WD)/nginx_reload

CALADAN_SYNC=$(WD)/caladan_sync
FUGU_SYNC=$(WD)/fugu_sync
PIKVM_SYNC=$(WD)/pikvm_sync

CALADAN_TRIGGER=$(WD)/caladan_trigger
FUGU_TRIGGER=$(WD)/fugu_trigger
PIKVM_TRIGGER=$(WD)/pikvm_trigger

all: renew_certs $(CALADAN_TRIGGER) $(FUGU_TRIGGER) $(PIKVM_TRIGGER) $(NGINX_RELOAD) refresh_pg

###############################################################################

ACME_DIR=/srv/certs/acme
DOMAIN=monotremata.xyz
CERT_PATH=$(ACME_DIR)/$(DOMAIN)

FULLCHAIN=$(CERT_PATH)/fullchain.cer
CERT=$(CERT_PATH)/$(DOMAIN).cer
KEY=$(CERT_PATH)/$(DOMAIN).key

###############################################################################

SSH_KEY=/srv/certs/ssh/users/dags/id_ed25519

###############################################################################
# Renew the certificates using acme.sh. Because `renew_certs` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

$(FULLCHAIN): renew_certs
$(CERT): renew_certs
$(KEY): renew_certs

GOPASS=doas -u gopass gopass
LINODE_TOKEN = $(shell $(GOPASS) linode.com/token)

DOCKER_IMAGE=neilpang/acme.sh
ACME_DATA_DIR=/mnt/docker_volumes/acmesh/data

RENEW_CMD="/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" --config-home "/acme.sh"

renew_certs:
	@echo "renewing certs"
	@docker run --rm -it \
		-v $(ACME_DATA_DIR):/acme.sh \
		-v $(CERT_PATH):/acme.sh/$(DOMAIN) \
		-e "LINODE_V4_API_KEY=$(LINODE_TOKEN)" \
		$(DOCKER_IMAGE) \
		$(RENEW_CMD)

###############################################################################
# Sync the certs to remote hosts and trigger DAGs there

RSYNC_ARGS=--archive --delete --compress --verbose --human-readable --rsh "ssh -i $(SSH_KEY)"

$(CALADAN_SYNC): $(FULLCHAIN) $(CERT) $(KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$^ \
		dags@caladan:$(ACME_DIR)
	touch $@

$(FUGU_SYNC): $(FULLCHAIN) $(CERT) $(KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas rsync" \
		$^ \
		dags@fugu:$(ACME_DIR)
	touch $@

KVMD_PST_DATA = /var/lib/kvmd/pst/data

$(PIKVM_SYNC): $(FULLCHAIN) $(CERT) $(KEY)
	mkdir -p $(@D)
	rsync \
		$(RSYNC_ARGS) \
		--rsync-path="doas kvmd-pstrun -- rsync" \
		$^ \
		dags@pikvm:$(KVMD_PST_DATA)/acme
	touch $@

define remote_dag_trigger
	mkdir -p $(@D)
	ssh -i $(SSH_KEY) dags@$(1) "doas /srv/dags/$(1)/$(2)/run.sh"
	touch $@
endef

$(CALADAN_TRIGGER): $(CALADAN_SYNC)
	$(call remote_dag_trigger, caladan, acme_refresh)

$(FUGU_TRIGGER): $(FUGU_SYNC)
	$(call remote_dag_trigger, fugu, acme_refresh)

$(PIKVM_TRIGGER): $(PIKVM_SYNC)
	$(call remote_dag_trigger, pikvm, acme_refresh)

###############################################################################
# Reload the nginx instance running on my reverse proxy docker-compose service
# so that it uses the new certificates.
# The target is just an empty sentinel target with no meaningful data other
# than its modification date.
# So far, the nginx instance running on `narwhal` only uses the `monotremata`
# and `narwhal` certificates, so it only needs to be reloaded if those are
# updated

NGINX_COMPOSE_FILE=/srv/services/reverse_proxy/docker-compose.yml

$(NGINX_RELOAD): $(FULLCHAIN) $(KEY)
	mkdir -p $(@D)
	docker-compose \
		--file $(NGINX_COMPOSE_FILE) \
		exec nginx \
		nginx -s reload
	touch $@

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
