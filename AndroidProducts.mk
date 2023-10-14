PRODUCT_MAKEFILES := \
	$(LOCAL_DIR)/evolution_rosemary.mk

COMMON_LUNCH_CHOICES := \
    $(foreach variant, user userdebug eng, evolution_rosemary-$(variant))
