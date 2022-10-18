WD=/var/lib/dags/acme_renew

.PHONY: all refresh_pg renew_certs

NGINX_RELOAD=$(WD)/nginx_reload

all: renew_certs $(NGINX_RELOAD) refresh_pg

###############################################################################

DOMAIN=monotremata.xyz
CERT_PATH=/mnt/certs/acme/$(DOMAIN)

CERT=$(CERT_PATH)/fullchain.cer
KEY=$(CERT_PATH)/$(DOMAIN).key

###############################################################################
# Renew the certificates using acme.sh. Because `renew_certs` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

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
# Reload the nginx instance running on my reverse proxy docker-compose service
# so that it uses the new certificates.
# The target is just an empty sentinel target with no meaningful data other
# than its modification date.
# So far, the nginx instance running on `narwhal` only uses the `monotremata`
# and `narwhal` certificates, so it only needs to be reloaded if those are
# updated

NGINX_COMPOSE_FILE=/srv/services/reverse_proxy/docker-compose.yml

$(NGINX_RELOAD): $(CERT) $(KEY)
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

$(PG_CERT): $(CERT)
	mkdir -p $(@D)
	rsync --copy-links $< $@

$(PG_KEY): $(KEY)
	mkdir -p $(@D)
	rsync --copy-links $< $@

refresh_pg: $(PG_CERT) $(PG_KEY)
