###############################################################################

WD = /var/lib/dags/acme
CERTS_DIR = $(WD)/certs
DOMAIN = monotremata.xyz
DOMAIN_CERTS_DIR = $(CERTS_DIR)/$(DOMAIN)

###############################################################################

ACME_CA_FILE = $(DOMAIN_CERTS_DIR)/ca.cer
ACME_FULLCHAIN_FILE = $(DOMAIN_CERTS_DIR)/fullchain.cer
ACME_KEY_FILE = $(DOMAIN_CERTS_DIR)/$(DOMAIN).key

###############################################################################

JSON_SECRET = $(WD)/secret.json
SECRET_UPDATED = $(WD)/secret_updated

###############################################################################

K8S_CA_FILE = /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
K8S_TOKEN_FILE = /var/run/secrets/kubernetes.io/serviceaccount/token
K8S_TOKEN = $(shell cat $(K8S_TOKEN_FILE))
K8S_APISERVER = $(KUBERNETES_SERVICE_HOST):$(KUBERNETES_SERVICE_PORT_HTTPS)
K8S_SECRERTS_URL = https://$(K8S_APISERVER)/api/v1/namespaces/$(CERT_NAMESPACE)/secrets

###############################################################################

.PHONY: all sync_certs

all: sync_certs $(SECRET_UPDATED)

###############################################################################

RSYNCD_HOST = narwhal
RSYNCD_USER = user
REMOTE_ACME_PATH=rsync://$(RSYNCD_USER)@$(RSYNCD_HOST)/acme
RSYNC_OPTS=--archive --delete --acls --xattrs --compress --verbose --human-readable

sync_certs:
	@mkdir -p $(CERTS_DIR)
	@echo "pulling certs with rsync"
	@rsync \
		$(RSYNC_OPTS) \
		$(REMOTE_ACME_PATH) \
		$(CERTS_DIR)

$(ACME_CA_FILE): sync_certs
$(ACME_FULLCHAIN_FILE): sync_certs
$(ACME_KEY_FILE): sync_certs

###############################################################################

$(JSON_SECRET): $(ACME_KEY_FILE) $(ACME_FULLCHAIN_FILE) $(ACME_KEY_FILE)
	@echo "building json secret file"
	@jq --null-input --raw-output \
		--arg kind "Secret" \
		--arg name "$(SECRET_NAME)" \
		--arg cacert "$$(base64 -w 0 $(ACME_CA_FILE))" \
		--arg tlscert "$$(base64 -w 0 $(ACME_FULLCHAIN_FILE))" \
		--arg tlskey "$$(base64 -w 0 $(ACME_KEY_FILE))" \
		'{ kind: $$kind, metadata: {name: $$name}, data: { "ca.crt": $$cacert, "tls.crt": $$tlscert, "tls.key": $$tlskey }}' \
		> $@

###############################################################################

define k8s_api
	curl \
		--include \
		--request $(1) \
        --write-out "%{http_code}" \
        --output /dev/null \
		--cacert "$(K8S_CA_FILE)" \
		--header "Authorization: Bearer $(K8S_TOKEN)" \
		--header 'Accept: application/json' \
		--header "Content-Type: application/json"
endef

define get_secret
	$(call k8s_api,GET) $(K8S_SECRERTS_URL)/$(SECRET_NAME)
endef

define post_secret
	$(call k8s_api,POST) $(K8S_SECRERTS_URL) --data @$(1)
endef

define put_secret
	$(call k8s_api,PUT) $(K8S_SECRERTS_URL)/$(SECRET_NAME) --data @$(1)
endef

$(SECRET_UPDATED): $(JSON_SECRET)
	@mkdir -p $(@D)
	@GET_STATUS_CODE=$$($(call get_secret)); \
	if [ "$${GET_STATUS_CODE}" = "404" ]; then \
		echo "adding cert"; \
		POST_STATUS_CODE=$$($(call post_secret,$^)); \
		[ "$${POST_STATUS_CODE}" = "201" ] && touch $@; \
	elif [ "$${GET_STATUS_CODE}" = "200" ]; then \
		echo "updating existing cert"; \
		PUT_STATUS_CODE=$$($(call put_secret,$^)); \
		[ "$${PUT_STATUS_CODE}" = "200" ] && touch $@; \
	fi
	@echo "done"

###############################################################################
