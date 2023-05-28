DOMAIN_NAME ?= monotremata.xyz
RECORD_NAME ?= wg
TTL ?= 300

WD=/var/lib/dags/ddns

GET_IP_URL = ifconfig.me/ip
HETZNER_API_URL = https://dns.hetzner.com/api/v1

STATE_DIR = $(WD)/$(RECORD_NAME).$(DOMAIN_NAME)

HOST_IP = $(STATE_DIR)/host_ip.txt

UPDATE_RECORD_HETZNER = $(STATE_DIR)/updated_record_hetzner

CURL = curl --silent

HETZNER_TOKEN = $(shell cat /srv/secrets/hetzner_token)
AUTH_CURL_HETZNER = $(CURL) -H 'Auth-API-Token: $(HETZNER_TOKEN)'
HETZNER_ZONE_ID = $(STATE_DIR)/hetzner_zone_id.txt
HETZNER_RECORD_ID = $(STATE_DIR)/hetzner_record_id.txt
HETZNER_UPDATE_BODY = $(STATE_DIR)/hetzner_update_body.json

define get_id_hetzner
	jq --raw-output '.["$(1)"][] | select(.["name"] == "$(2)")["id"]'
endef

.PHONY: all force clean

all: $(UPDATE_RECORD_HETZNER)

# Hetzner-specific #############################################################

# because the ip state is only updated when the IP changes, we should only need
# to update the record when that happens
$(UPDATE_RECORD_HETZNER): $(HETZNER_UPDATE_BODY) $(HETZNER_RECORD_ID)
	@echo "updating hetzner record"
	@mkdir -p $(@D)
	@$(AUTH_CURL_HETZNER) \
		-H 'Content-Type: application/json' \
		"$(HETZNER_API_URL)/records/$$(cat $(HETZNER_RECORD_ID))" \
		-X "PUT" \
		--data @$(HETZNER_UPDATE_BODY)
	@touch $@

$(HETZNER_UPDATE_BODY): $(HOST_IP) $(HETZNER_ZONE_ID)
	@jq --null-input --raw-output \
		--arg value $$(cat $(HOST_IP)) \
		--arg ttl $(TTL) \
		--arg name $(RECORD_NAME) \
		--arg zone_id $$(cat $(HETZNER_ZONE_ID)) \
		'{ "value": $$value, "ttl": $$ttl | tonumber, "type": "A", "name": $$name, "zone_id": $$zone_id }' > \
	$@

$(HETZNER_ZONE_ID):
	@echo "fetching hetzner zone id"
	@mkdir -p $(@D)
	@$(AUTH_CURL_HETZNER) \
		$(HETZNER_API_URL)/zones | \
	$(call get_id_hetzner,zones,$(DOMAIN_NAME)) | \
	tee $@

$(HETZNER_RECORD_ID): $(HETZNER_ZONE_ID)
	@echo "fetching hetzner record id"
	@mkdir -p $(@D)
	@$(AUTH_CURL_HETZNER) \
		$(HETZNER_API_URL)/records?zone_id=$$(cat $<) | \
	$(call get_id_hetzner,records,$(RECORD_NAME)) | \
	tee $@

# Common #############################################################

# this target depends on a PHONY so that it is attempted every time, but the
# target file should only be updated is the current host ip is different to the
# saved one
$(HOST_IP): force
	@echo "fetching host IP"
	@mkdir -p $(@D)
	@current_ip=$$($(CURL) $(GET_IP_URL)); \
	echo "$$current_ip"; \
	if [ ! -f $@ ] || [ "$$current_ip" != "$$(cat $@)" ]; then \
		echo "updating stored IP"; \
		echo "$$current_ip" | tee $@; \
	fi

clean:
	rm -fr $(STATE_DIR)
