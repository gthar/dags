WD=/var/lib/dags/letsencrypt_renew

RENEW=$(WD)/renewed_certs
NGINX_RELOAD=$(WD)/nginx_reload
PROSODY_IMPORT=$(WD)/prosody_import
PROSODY_RELOAD=$(WD)/prosody_reload

.PHONY: all

all: $(RENEW) $(NGINX_RELOAD) $(PROSODY_RELOAD)

################################################################################

LETSENCRYPT_COMPOSE_FILE=/srv/services/letsencrypt/docker-compose.yml

$(RENEW):
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
