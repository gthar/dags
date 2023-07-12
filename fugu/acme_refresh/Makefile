# Note: since I am assuming GNU Make and this host runs OpenBSD, remember to
# run this dag using `gmake` instead of `make`

WD=/var/lib/dags/acme_refresh

SMTPD_RESTART=$(WD)/smtpd_restart
DOVECOT_RELOAD=$(WD)/dovecot_reload

.PHONY: all

all: $(SMTPD_RESTART) $(DOVECOT_RELOAD)


###############################################################################

ACME_DIR=/srv/certs/acme
DOMAIN=monotremata.xyz
MAIL_CERT_PATH=$(ACME_DIR)/mail.$(DOMAIN)
MAIL_CERT=$(MAIL_CERT_PATH)/fullchain.pem
MAIL_KEY=$(MAIL_CERT_PATH)/key.pem

###############################################################################

SSL_PATH=/etc/ssl
CERT_DEST=$(SSL_PATH)/fullchain.pem
KEY_DEST=$(SSL_PATH)/private/key.pem

$(CERT_DEST): $(MAIL_CERT)
	install -m 444 $< $@

$(KEY_DEST): $(MAIL_KEY)
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
