DOMAIN_NAME ?= monotremata.xyz
RECORD_NAME ?= wg

WD=/var/lib/dags/ddns

API_URL = https://api.linode.com/v4
GET_IP_URL = ifconfig.me/ip
STATE_DIR = $(WD)/$(RECORD_NAME).$(DOMAIN_NAME)

HOST_IP = $(STATE_DIR)/host_ip.txt
DOMAIN_ID = $(STATE_DIR)/domain_id.txt
RECORD_ID = $(STATE_DIR)/record_id.txt
UPDATE_RECORD = $(STATE_DIR)/updated_record

LINODE_TOKEN = $(shell gopass linode.com/token)

CURL = curl --silent
AUTH_CURL = $(CURL) -H "Authorization: Bearer $(LINODE_TOKEN)"

define get_id
	jq '.["data"][] | select(.["$(1)"] == "$(2)")["id"]'
endef

.PHONY: force clean

# because the ip state is only updated when the IP changes, we should only need
# to update the record when that happens
$(UPDATE_RECORD): $(HOST_IP) $(DOMAIN_ID) $(RECORD_ID)
	@echo "updating record"
	@$(AUTH_CURL) \
        -H "Content-Type: application/json" \
        -X PUT -d '{ "target": "'"$$(cat $<)"'" }' \
        "$(API_URL)/domains/$$(cat $(DOMAIN_ID))/records/$$(cat $(RECORD_ID))"
	@touch $@

# the domain id should not change and this should only ever need to run once
$(DOMAIN_ID):
	@echo "fetching domain id"
	@mkdir -p $(@D)
	@$(AUTH_CURL) $(API_URL)/domains | \
	$(call get_id,domain,$(DOMAIN_NAME)) | \
	tee $@

# the register id should not change and this should only ever need to run once
$(RECORD_ID): $(DOMAIN_ID)
	@echo "fetching record id"
	@mkdir -p $(@D)
	@$(AUTH_CURL) $(API_URL)/domains/$$(cat $<)/records | \
	$(call get_id,name,$(RECORD_NAME)) | \
	tee $@

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
