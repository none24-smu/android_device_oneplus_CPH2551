/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H

#define BTM_DEF_LOCAL_NAME "OnePlus CPH2551"

// Networking, Capturing, Object Transfer
// MAJOR CLASS: COMPUTER
// MINOR CLASS: UNCLASSIFIED
#define BTA_DM_COD {0x1A, 0x01, 0x0C}

#define BTIF_HF_SERVICES (BTA_HSP_SERVICE_MASK)
#define BTIF_HF_SERVICE_NAMES { BTIF_HSAG_SERVICE_NAME, NULL }

#define BTA_DISABLE_DELAY 1000 /* in milliseconds */

#define BLE_VND_INCLUDED TRUE

// Increase MAX_L2CAP_CHANNELS for Bluetooth support
#undef MAX_L2CAP_CHANNELS
#define MAX_L2CAP_CHANNELS 32

// Increase BTM_MAX_SCO_LINKS
#undef BTM_MAX_SCO_LINKS
#define BTM_MAX_SCO_LINKS 4

#endif
