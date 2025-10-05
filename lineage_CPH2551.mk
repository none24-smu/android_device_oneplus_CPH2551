#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from CPH2551 device
$(call inherit-product, device/oneplus/CPH2551/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier
PRODUCT_NAME := lineage_CPH2551
PRODUCT_DEVICE := CPH2551
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := CPH2551
PRODUCT_MANUFACTURER := OnePlus

PRODUCT_SYSTEM_NAME := CPH2551
PRODUCT_SYSTEM_DEVICE := OP5973L1

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=$(PRODUCT_SYSTEM_DEVICE) \
    TARGET_PRODUCT=$(PRODUCT_SYSTEM_NAME)
