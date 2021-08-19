# swanagent package

SWANAGENT = swanagent_1.0_$(CONFIGURED_ARCH).deb
$(SWANAGENT)_SRC_PATH = $(SRC_PATH)/swan-agent-for-sonic
SONIC_MAKE_DEBS += $(SWANAGENT)
