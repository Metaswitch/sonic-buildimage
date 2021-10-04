# docker image for fpm-framewave

DOCKER_FRAMEWAVE_PROXY_STEM = docker-framewave-proxy
DOCKER_FRAMEWAVE_PROXY = $(DOCKER_FRAMEWAVE_PROXY_STEM).gz
DOCKER_FRAMEWAVE_PROXY_DBG = $(DOCKER_FRAMEWAVE_PROXY_STEM)-$(DBG_IMAGE_MARK).gz

$(DOCKER_FRAMEWAVE_PROXY)_PATH = $(DOCKERS_PATH)/$(DOCKER_FRAMEWAVE_PROXY_STEM)
$(DOCKER_FRAMEWAVE_PROXY)_DEPENDS += $(FRAMEWAVE_PROXY)
$(DOCKER_FRAMEWAVE_PROXY)_LOAD_DOCKERS += $(DOCKER_CONFIG_ENGINE_BUSTER)
SONIC_DOCKER_IMAGES += $(DOCKER_FRAMEWAVE_PROXY)
SONIC_INSTALL_DOCKER_IMAGES += $(DOCKER_FRAMEWAVE_PROXY)

$(DOCKER_FRAMEWAVE_PROXY)_CONTAINER_NAME = framewave-proxy
$(DOCKER_FRAMEWAVE_PROXY)_VERSION = 1.0.0
$(DOCKER_FRAMEWAVE_PROXY)_PACKAGE_NAME = framewave-proxy
$(DOCKER_FRAMEWAVE_PROXY)_RUN_OPT += --privileged -t
$(DOCKER_FRAMEWAVE_PROXY)_RUN_OPT += -v /etc/sonic:/etc/sonic:ro
$(DOCKER_FRAMEWAVE_PROXY)_RUN_OPT += -v /host/warmboot:/var/warmboot

$(DOCKER_FRAMEWAVE_PROXY)_FILES += $(SUPERVISOR_PROC_EXIT_LISTENER_SCRIPT)
