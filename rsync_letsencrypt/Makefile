.PHONY: all fetch_certs reload_nginx refresh_pg

all: fetch_certs reload_nginx refresh_pg

LETSENCRYPT_PATH=/mnt/letsencrypt

###############################################################################
# Fetch the certificates from my remote server using rsync
#
# The combination of `--info=NAME` and pipe into grep means this target will
# have a non-zero exit code if nothing has been updated.
# This way, the other targets will run only when some certificate has been
# updated

REMOTE_LETSENCRYPT_PATH=rsync://user@caladan/letsencrypt
RSYNCD_PASSWD=/mnt/secrets/rsyncd_password
RSYNC_OPTS=--archive --delete --acls --xattrs --compress --human-readable

fetch_certs:
	rsync \
		$(RSYNC_OPTS) \
		--info=NAME \
		--password-file=$(RSYNCD_PASSWD) \
		$(REMOTE_LETSENCRYPT_PATH) \
		$(LETSENCRYPT_PATH) #| \
	# grep .

###############################################################################
# Reload the nginx instance running on my reverse proxy docker-compose service
# so that it uses the new certificates

NGINX_COMPOSE_FILE=/srv/services/reverse_proxy/docker-compose.yml

reload_nginx: fetch_certs
	docker-compose \
		--file $(NGINX_COMPOSE_FILE) \
		exec nginx \
		nginx -s reload

###############################################################################
# Copy the certificate for the postgresql domain to the folder where postgre
# service expects it
# After running the fetch_certs target, the postgresql fullchain.pem and
# privkey.pem should be available. Copy those to the postgre SSL folder.

PG_DOMAIN=pg.monotremata.xyz
PG_SSL_PATH=/mnt/docker_volumes/postgres/ssl

$(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/fullchain.pem: fetch_certs
$(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/privkey.pem: fetch_certs

$(PG_SSL_PATH)/server.crt: $(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/fullchain.pem
	mkdir -p $(@D)
	rsync --copy-links $< $@

$(PG_SSL_PATH)/server.key: $(LETSENCRYPT_PATH)/live/$(PG_DOMAIN)/privkey.pem
	mkdir -p $(@D)
	rsync --copy-links $< $@

refresh_pg: $(PG_SSL_PATH)/server.crt $(PG_SSL_PATH)/server.key
