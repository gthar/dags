WD=/var/lib/dags/acme_rsync

.PHONY: all refresh_pg sync_certs

NGINX_RELOAD=$(WD)/nginx_reload
PROSODY_RELOAD=$(WD)/prosody_reload

all: sync_certs $(NGINX_RELOAD) $(PROSODY_RELOAD) refresh_pg

###############################################################################

DOMAIN=monotremata.xyz
CERT_PATH=/srv/certs/$(DOMAIN)
CERT=$(CERT_PATH)/fullchain.cer
KEY=$(CERT_PATH)/$(DOMAIN).key

###############################################################################
# Sync the certificates using rsync. Because `sync` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

$(CERT): sync_certs
$(KEY): sync_certs

REMOTE_ACME_PATH=rsync://user@narwhal/acme
RSYNCD_PASSWD=/srv/secrets/rsyncd_password
RSYNC_OPTS=--archive --delete --acls --xattrs --compress --verbose --human-readable

sync_certs:
	mkdir -p $(CERTS_PATH)
	rsync \
		$(RSYNC_OPTS) \
		--password-file=$(RSYNCD_PASSWD) \
		$(REMOTE_ACME_PATH) \
		$(CERTS_PATH)

###############################################################################
# Reload the nginx instance running on my reverse proxy docker-compose service
# so that it uses the new certificates.
# The target is just an empty sentinel target with no meaningful data other
# than its modification date.
# So far, the nginx instance running on the `monotremata` certificates, so it
# only needs to be reloaded that is updated

NGINX_COMPOSE_FILE=/srv/services/www/docker-compose.yml

$(NGINX_RELOAD): $(MONOTREMATA_CERT) $(MONOTREMATA_KEY)
	mkdir -p $(@D)
	docker-compose \
		--file $(NGINX_COMPOSE_FILE) \
		exec nginx \
		nginx -s reload
	touch $@

###############################################################################

PROSODY_CERTS_PATH=/srv/volumes/xmpp/certs

PROSODY_CERT=$(PROSODY_CERTS_PATH)/monotremata.xyz.crt
PROSODY_KEY=$(PROSODY_CERTS_PATH)/monotremata.xyz.key

PROSODY_UID=101
PROSODY_GID=102

$(PROSODY_CERT): $(CERT)
	install -o $(PROSODY_UID) -g $(PROSODY_GID) -m 644 $< $@

$(PROSODY_KEY): $(KEY)
	install -o $(PROSODY_UID) -g $(PROSODY_GID) -m 600 $< $@

PROSODY_COMPOSE_FILE=/srv/services/xmpp/docker-compose.yml

$(PROSODY_RELOAD): $(PROSODY_CERT) $(PROSODY_KEY)
	mkdir -p $(@D)
	docker-compose --file $(PROSODY_COMPOSE_FILE) exec \
		prosody prosodyctl reload
	touch $@

###############################################################################
# Copy the certificate for the postgresql domain to the folder where postgre
# service expects it

PG_SSL_PATH=/srv/volumes/postgres/ssl
PG_CERT=$(PG_SSL_PATH)/server.crt
PG_KEY=$(PG_SSL_PATH)/server.key

$(PG_CERT): $(CERT)
	mkdir -p $(@D)
	rsync --copy-links $< $@

$(PG_KEY): $(KEY)
	mkdir -p $(@D)
	rsync --copy-links $< $@

refresh_pg: $(PG_CERT) $(PG_KEY)
