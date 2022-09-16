# Note: since I am assuming GNU Make and this host run OpenBSD, remember to run
# this dag using `gmake` instead of `make`

WD=/var/lib/dags/acme_rsync

SMTPD_RESTART=$(WD)/smtpd_restart
DOVECOT_RELOAD=$(WD)/dovecot_reload
SYNC_CERTS=$(WD)/sync_certs

.PHONY: all sync_certs

all: sync_certs $(SMTPD_RESTART) $(DOVECOT_RELOAD)


###############################################################################

CERTS_PATH=/srv/certs/acme

MONOTREMATA_DOMAIN=monotremata.xyz
MONOTREMATA_PATH=$(CERTS_PATH)/$(MONOTREMATA_DOMAIN)
MONOTREMATA_CERT=$(MONOTREMATA_PATH)/fullchain.cer
MONOTREMATA_KEY=$(MONOTREMATA_PATH)/$(MONOTREMATA_DOMAIN).key

###############################################################################
# Sync the certificates using rsync. Because `sync` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

$(MONOTREMATA_CERT): $(SYNC_CERTS)
$(MONOTREMATA_KEY): $(SYNC_CERTS)

REMOTE_ACME_PATH=rsync://user@narwhal/acme
RSYNCD_PASSWD=/srv/secrets/rsyncd_password
RSYNC_OPTS=--archive --delete --compress --verbose --human-readable

sync_certs:
	mkdir -p $(CERTS_PATH)
	rsync \
		$(RSYNC_OPTS) \
		--password-file=$(RSYNCD_PASSWD) \
		$(REMOTE_ACME_PATH) \
		$(CERTS_PATH)

###############################################################################

SSL_PATH=/etc/ssl
CERT_DEST=$(SSL_PATH)/monotremata.xyz.fullchain.pem
KEY_DEST=$(SSL_PATH)/private/monotremata.xyz.key

$(CERT_DEST): $(MONOTREMATA_CERT)
	install -m 444 $< $@

$(KEY_DEST): $(MONOTREMATA_KEY)
	install -m 400 $< $@

###############################################################################

$(SMTPD_RESTART): $(CERT_DEST) $(KEY_DEST)
	mkdir -p $(@D)
	rcctl restart smtpd
	touch $@

###############################################################################

$(DOVECOT_RELOAD): $(CERT_DEST) $(KEY_DEST)
	mkdir -p $(@D)
	rcctl reload dovecot
	touch $@

###############################################################################
