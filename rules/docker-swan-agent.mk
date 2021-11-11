# docker image for swan-agent

DOCKER_SWAN_AGENT_STEM = docker-swan-agent
DOCKER_SWAN_AGENT = $(DOCKER_SWAN_AGENT_STEM).gz

$(DOCKER_SWAN_AGENT)_PATH = $(DOCKERS_PATH)/$(DOCKER_SWAN_AGENT_STEM)
$(DOCKER_SWAN_AGENT)_DEPENDS += $(SWANAGENT)
$(DOCKER_SWAN_AGENT)_LOAD_DOCKERS += $(DOCKER_CONFIG_ENGINE_BUSTER)

$(DOCKER_SWAN_AGENT)_CONTAINER_NAME = swan-agent
$(DOCKER_SWAN_AGENT)_VERSION = 1.0.0
$(DOCKER_SWAN_AGENT)_PACKAGE_NAME = swan-agent
$(DOCKER_SWAN_AGENT)_RUN_OPT += --privileged -it
$(DOCKER_SWAN_AGENT)_RUN_OPT += --network=host

$(DOCKER_SWAN_AGENT)_FILES += $(SUPERVISOR_PROC_EXIT_LISTENER_SCRIPT)

SONIC_DOCKER_IMAGES += $(DOCKER_SWAN_AGENT)
SONIC_INSTALL_DOCKER_IMAGES += $(DOCKER_SWAN_AGENT)

$(DOCKER_ORCHAGENT)_RUN_OPT += -v /etc/sonic:/root/config/:ro