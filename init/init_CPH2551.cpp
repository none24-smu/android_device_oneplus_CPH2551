/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/properties.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include "property_service.h"
#include "vendor_init.h"

using android::base::GetProperty;

void property_override(char const prop[], char const value[], bool add = true) {
    prop_info *pi;

    pi = (prop_info *) __system_property_find(prop);
    if (pi)
        __system_property_update(pi, value, strlen(value));
    else if (add)
        __system_property_add(prop, strlen(prop), value, strlen(value));
}

void load_device_properties() {
    // Set device-specific properties
    property_override("ro.product.model", "CPH2551");
    property_override("ro.product.device", "OP5973L1");
    property_override("ro.product.name", "CPH2551");
    property_override("ro.build.product", "OP5973L1");
}

void vendor_load_properties() {
    LOG(INFO) << "Loading vendor specific properties for CPH2551";
    load_device_properties();
}
