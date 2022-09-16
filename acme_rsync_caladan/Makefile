WD=/var/lib/dags/acme_rsync

.PHONY: all refresh_pg renew_certs

NGINX_RELOAD=$(WD)/nginx_reload
PROSODY_IMPORT=$(WD)/prosody_import
PROSODY_RELOAD=$(WD)/prosody_reload

all: sync_certs $(NGINX_RELOAD) refresh_pg

###############################################################################

CERTS_PATH=/srv/certs/acme

MONOTREMATA_DOMAIN=monotremata.xyz
MONOTREMATA_PATH=$(CERTS_PATH)/$(MONOTREMATA_DOMAIN)
MONOTREMATA_CERT=$(MONOTREMATA_PATH)/fullchain.cer
MONOTREMATA_KEY=$(MONOTREMATA_PATH)/$(MONOTREMATA_DOMAIN).key

NARWHAL_DOMAIN=narwhal.monotremata.xyz
NARWHAL_PATH=$(CERTS_PATH)/$(NARWHAL_DOMAIN)
NARWHAL_CERT=$(NARWHAL_PATH)/fullchain.cer
NARWHAL_KEY=$(NARWHAL_PATH)/$(NARWHAL_DOMAIN).key

CALADAN_DOMAIN=caladan.monotremata.xyz
CALADAN_PATH=$(CERTS_PATH)/$(CALADAN_DOMAIN)
CALADAN_CERT=$(CALADAN_PATH)/fullchain.cer
CALADAN_KEY=$(CALADAN_PATH)/$(CALADAN_DOMAIN).key

XMPP_DOMAIN=xmpp.monotremata.xyz
XMPP_PATH=$(CERTS_PATH)/$(XMPP_DOMAIN)
XMPP_CERT=$(XMPP_PATH)/fullchain.cer
XMPP_KEY=$(XMPP_PATH)/$(XMPP_DOMAIN).key

###############################################################################
# Renew the certificates using acme.sh. Because `renew_certs` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

$(MONOTREMATA_CERT): sync_certs
$(MONOTREMATA_KEY): sync_certs
$(NARWHAL_CERT): sync_certs
$(NARWHAL_KEY): sync_certs
$(CALADAN_CERT): sync_certs
$(CALADAN_KEY): sync_certs
$(XMPP_CERT): sync_certs
$(XMPP_KEY): sync_certs

REMOTE_ACME_PATH=rsync://user@narwhal/acme
RSYNCD_PASSWD=/srv/secrets/rsyncd_password
RSYNC_OPTS=--archive --delete --acls --xattrs --compress --verbose --human-readable

sync_certs:
	mkdir -p $(CERTS_PATH)
	rsync \
		$(RSYNC_OPTS) \
		--password-file=$(RSYNCD_PASSWD) \
		$(REMOTE_LETSENCRYPT_PATH) \
		$(CERTS_PATH)

###############################################################################
# Reload the nginx instance running on my reverse proxy docker-compose service
# so that it uses the new certificates.
# The target is just an empty sentinel target with no meaningful data other
# than its modification date.
# So far, the nginx instance running on the `monotremata` certificates, so it
# only needs to be reloaded that is updated

NGINX_COMPOSE_FILE=/srv/services/reverse_proxy/docker-compose.yml

$(NGINX_RELOAD): $(MONOTREMATA_CERT) $(MONOTREMATA_KEY)
	mkdir -p $(@D)
	docker-compose \
		--file $(NGINX_COMPOSE_FILE) \
		exec nginx \
		nginx -s reload
	touch $@

###############################################################################

PROSODY_COMPOSE_FILE=/srv/services/xmpp/docker-compose.yml

$(PROSODY_IMPORT): $(XMPP_CERT) $(XMPP_KEY)
	mkdir -p $(@D)
	docker-compose \
		--file $(PROSODY_COMPOSE_FILE) \
		exec prosody \
		prosodyctl --root cert import /etc/letsencrypt/live
	touch $@

$(PROSODY_RELOAD): $(PROSODY_IMPORT)
	mkdir -p $(@D)
	docker-compose \
		--file $(PROSODY_COMPOSE_FILE) \
		exec prosody \
		prosodyctl reload
	touch $@

###############################################################################
# Copy the certificate for the postgresql domain to the folder where postgre
# service expects it

PG_SSL_PATH=/srv/volumes/postgres/ssl
PG_CERT=$(PG_SSL_PATH)/server.crt
PG_KEY=$(PG_SSL_PATH)/server.key

$(PG_CERT): $(CALADAN_CERT)
	mkdir -p $(@D)
	rsync --copy-links $< $@

$(PG_KEY): $(CALADAN_KEY)
	mkdir -p $(@D)
	rsync --copy-links $< $@

refresh_pg: $(PG_CERT) $(PG_KEY)
