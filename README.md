# Device Tree for OnePlus CPH2551

## Device Specifications

| Feature                 | Specification                                    |
| :---------------------- | :----------------------------------------------- |
| Codename                | CPH2551 (OP5973L1)                               |
| Chipset                 | Qualcomm SM8550 Snapdragon 8 Gen 2 (4 nm)        |
| Memory                  | 16 GB RAM                                        |
| Shipped Android Version | Android 13                                       |

## Device Picture

![OnePlus CPH2551](https://oasis.opstatics.com/content/dam/oasis/page/2024/global/product/open/red-specs.png)

## Quick Start

### 1. Run Setup Script

This will extract the stock ROM and clone the kernel source:

```bash
cd /media/smuserverv1/SSD\ RAID/android_device_oneplus_CPH2551
./scripts/setup.sh
```

### 2. Mount Stock Images

```bash
sudo ./scripts/mount_images.sh
```

### 3. Extract Vendor Blobs

After populating `proprietary-files.txt`:

```bash
./extract-files.sh /media/smuserverv1/SSD\ RAID/CPH2551_mounted
```

### 4. Unmount Images

```bash
sudo ./scripts/umount_images.sh
```

## Full Build Instructions

### Initialize the LineageOS source repository

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs
```

### Sync the repository

```bash
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### Clone this device tree

```bash
git clone https://github.com/none24-smu/android_device_oneplus_CPH2551.git device/oneplus/CPH2551
```

### Clone kernel source

```bash
git clone https://github.com/OnePlusOSS/android_kernel_common_oneplus_sm8550.git \
    -b oneplus/sm8550_v_15.0.0_oneplus_open kernel/oneplus/sm8550
```

### Clone vendor blobs (after creating vendor repo)

```bash
git clone https://github.com/none24-smu/android_vendor_oneplus_CPH2551.git vendor/oneplus/CPH2551
```

### Build

```bash
source build/envsetup.sh
lunch lineage_CPH2551-userdebug
mka bacon -j$(nproc --all)
```

## Development Guide

For a detailed step-by-step guide to completing this device tree, see [BUILDING.md](BUILDING.md).

This includes:
- Kernel configuration
- Vendor blob extraction
- Hardware-specific configurations (Audio, Camera, Sensors, etc.)
- SELinux policies
- Testing and debugging

## Copyright

```
#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
```
