WD=/var/lib/dags/acme_rsync

.PHONY: all sync_certs

all: sync_certs

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
# Sync the certificates using rsync. Because `sync` is a phony
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
		$(REMOTE_ACME_PATH) \
		$(CERTS_PATH)
