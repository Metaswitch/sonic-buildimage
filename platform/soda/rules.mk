include $(PLATFORM_PATH)/sai.mk
include $(PLATFORM_PATH)/docker-syncd-soda.mk
include $(PLATFORM_PATH)/onie.mk
include $(PLATFORM_PATH)/kvm-image.mk

# Inject SODA sai into syncd
$(SYNCD)_DEPENDS += $(SODA_SAI)
$(SYNCD)_UNINSTALLS += $(SODA_SAI)

ifeq ($(ENABLE_SYNCD_RPC),y)
$(SYNCD)_DEPENDS += $(LIBSAITHRIFT_DEV)
endif

# Runtime dependency on SODA sai is set only for syncd
$(SYNCD)_RDEPENDS += $(SODA_SAI)

SONIC_ALL += $(SONIC_KVM_IMAGE)
