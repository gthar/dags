WD=/var/lib/dags/letsencrypt_renew

RENEW=$(WD)/renewed_certs
NGINX_RELOAD=$(WD)/nginx_reload
PROSODY_IMPORT=$(WD)/prosody_import
PROSODY_RELOAD=$(WD)/prosody_reload

.PHONY: all refresh_pg force

all: $(RENEW) $(NGINX_RELOAD) $(PROSODY_RELOAD) refresh_pg

LETSENCRYPT_PATH=/srv/letsencrypt

################################################################################

LETSENCRYPT_COMPOSE_FILE=/srv/services/letsencrypt/docker-compose.yml

$(RENEW): force
	mkdir -p $(@D)
	docker-compose \
		--file $(LETSENCRYPT_COMPOSE_FILE) \
		run --rm certbot \
		renew --deploy-hook "touch $@"

################################################################################

NGINX_COMPOSE_FILE=/srv/services/www/docker-compose.yml

$(NGINX_RELOAD): $(RENEW)
	mkdir -p $(@D)
	docker-compose \
		--file $(NGINX_COMPOSE_FILE) \
		exec nginx \
		nginx -s reload
	touch $@

################################################################################

PROSODY_COMPOSE_FILE=/srv/services/xmpp/docker-compose.yml

$(PROSODY_IMPORT): $(RENEW)
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

################################################################################

PG_DOMAIN=pg.caladan.monotremata.xyz
PG_SSL_PATH=/srv/volumes/postgres/ssl

$(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/fullchain.pem: $(SYNC)
$(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/privkey.pem: $(SYNC)

$(PG_SSL_PATH)/server.crt: $(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/fullchain.pem
	mkdir -p $(@D)
	rsync --copy-links $< $@

$(PG_SSL_PATH)/server.key: $(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/privkey.pem
	mkdir -p $(@D)
	rsync --copy-links $< $@

refresh_pg: $(PG_SSL_PATH)/server.crt $(PG_SSL_PATH)/server.key
