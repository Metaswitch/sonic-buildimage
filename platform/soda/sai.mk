SODA_SAI = libsaisoda_1.0_amd64.deb
$(SODA_SAI)_SRC_PATH = $(SRC_PATH)/soda
SONIC_MAKE_DEBS += $(SODA_SAI)
$(eval $(call add_conflict_package,$(SODA_SAI),$(LIBSAIVS_DEV)))
