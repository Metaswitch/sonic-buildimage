# docker image for fpm-framewave

DOCKER_FPM_FRAMEWAVE_STEM = docker-fpm-framewave
DOCKER_FPM_FRAMEWAVE = $(DOCKER_FPM_FRAMEWAVE_STEM).gz
DOCKER_FPM_FRAMEWAVE_DBG = $(DOCKER_FPM_FRAMEWAVE_STEM)-$(DBG_IMAGE_MARK).gz

$(DOCKER_FPM_FRAMEWAVE)_PATH = $(DOCKERS_PATH)/$(DOCKER_FPM_FRAMEWAVE_STEM)
$(DOCKER_FPM_FRAMEWAVE)_DEPENDS += $(FRAMEWAVE)
$(DOCKER_FPM_FRAMEWAVE)_LOAD_DOCKERS += $(DOCKER_CONFIG_ENGINE_BUSTER)
SONIC_DOCKER_IMAGES += $(DOCKER_FPM_FRAMEWAVE)

$(DOCKER_FPM_FRAMEWAVE)_CONTAINER_NAME = bgp
$(DOCKER_FPM_FRAMEWAVE)_VERSION = 1.0.0
$(DOCKER_FPM_FRAMEWAVE)_PACKAGE_NAME = framewave
$(DOCKER_FPM_FRAMEWAVE)_RUN_OPT += --privileged -t
$(DOCKER_FPM_FRAMEWAVE)_RUN_OPT += -v /etc/sonic:/etc/sonic:ro
$(DOCKER_FPM_FRAMEWAVE)_RUN_OPT += -v /var/log/bgp:/var/log/bgp:rw

$(DOCKER_FPM_FRAMEWAVE)_FILES += $(SUPERVISOR_PROC_EXIT_LISTENER_SCRIPT)
