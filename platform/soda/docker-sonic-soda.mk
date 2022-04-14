# docker image for Soda based sonic docker image

DOCKER_SONIC_SODA = docker-sonic-soda.gz
$(DOCKER_SONIC_SODA)_PATH = $(PLATFORM_PATH)/docker-sonic-soda
$(DOCKER_SONIC_SODA)_DEPENDS += $(SWSS) \
                                $(SYNCD_SODA) \
                                $(REDIS_TOOLS) \
                                $(REDIS_SERVER) \
                                $(PYTHON_SWSSCOMMON) \
                                $(LIBTEAMDCT) \
                                $(LIBTEAM_UTILS) \
                                $(SONIC_DEVICE_DATA)

$(DOCKER_SONIC_SODA)_PYTHON_DEBS += $(SONIC_UTILS)

$(DOCKER_SONIC_SODA)_PYTHON_WHEELS += $(SWSSSDK_PY2) \
                                      $(SONIC_PY_COMMON_PY2)

ifeq ($(INSTALL_DEBUG_TOOLS), y)
$(DOCKER_SONIC_SODA)_DEPENDS += $(SWSS_DBG) \
                                $(LIBSWSSCOMMON_DBG) \
                                $(LIBSAIREDIS_DBG) \
                                $(LIBSAISODA_DBG) \
                                $(SYNCD_SODA_DBG)
endif

ifeq ($(SONIC_ROUTING_STACK), framewave)
$(DOCKER_SONIC_SODA)_DEPENDS += $(FRAMEWAVE)
endif

$(DOCKER_SONIC_SODA)_FILES += $(CONFIGDB_LOAD_SCRIPT) \
                              $(ARP_UPDATE_SCRIPT) \
                              $(BUFFERS_CONFIG_TEMPLATE) \
                              $(QOS_CONFIG_TEMPLATE) \
                              $(CBF_CONFIG_TEMPLATE) \
                              $(SONIC_VERSION)

$(DOCKER_SONIC_SODA)_LOAD_DOCKERS += $(DOCKER_CONFIG_ENGINE_STRETCH)
SONIC_DOCKER_IMAGES += $(DOCKER_SONIC_SODA)
SONIC_STRETCH_DOCKERS += $(DOCKER_SONIC_SODA)
