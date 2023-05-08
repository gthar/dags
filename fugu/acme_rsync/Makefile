# Note: since I am assuming GNU Make and this host runs OpenBSD, remember to
# run this dag using `gmake` instead of `make`

WD=/var/lib/dags/acme_rsync

SMTPD_RESTART=$(WD)/smtpd_restart
DOVECOT_RELOAD=$(WD)/dovecot_reload
SYNC_CERTS=$(WD)/sync_certs

.PHONY: all sync_certs

all: sync_certs $(SMTPD_RESTART) $(DOVECOT_RELOAD)


###############################################################################

ACME_DIR=/srv/certs/acme
DOMAIN=monotremata.xyz
CERT_PATH=$(ACME_DIR)/$(DOMAIN)
CERT=$(CERT_PATH)/fullchain.cer
KEY=$(CERT_PATH)/$(DOMAIN).key

###############################################################################
# Sync the certificates using rsync. Because `sync` is a phony
# target, it will be run each time, but the certificate files will only be
# updated if a renewal happens

$(CERT): $(SYNC_CERTS)
$(KEY): $(SYNC_CERTS)

RSYNCD_HOST=10.0.24.106
RSYNCD_USER=user
RSYNCD_PASSWORD=/srv/secrets/rsyncd_password

REMOTE_ACME_PATH=rsync://$(RSYNCD_USER)@$(RSYNCD_HOST)/acme
RSYNC_OPTS=--archive --delete --compress --verbose --human-readable

sync_certs:
	mkdir -p $(ACME_DIR)
	@echo "running rsync"
	@export RSYNC_PASSWORD=$(RSYNC_PASSWORD); \
	rsync \
		--password-file $(RSYNCD_PASSWORD) \
		$(RSYNC_OPTS) \
		$(REMOTE_ACME_PATH) \
		$(ACME_DIR)

###############################################################################

SSL_PATH=/etc/ssl
CERT_DEST=$(SSL_PATH)/monotremata.xyz.fullchain.pem
KEY_DEST=$(SSL_PATH)/private/monotremata.xyz.key

$(CERT_DEST): $(CERT)
	install -m 444 $< $@

$(KEY_DEST): $(KEY)
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
