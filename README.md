# Device Tree for OnePlus CPH2551

## Device Specifications

| Feature                 | Specification                                    |
| :---------------------- | :----------------------------------------------- |
| Codename                | CPH2551 (OP5973L1)                               |
| Chipset                 | Qualcomm SM8550 Snapdragon 8 Gen 2 (4 nm)        |
| Memory                  | 16 GB RAM                                        |
| Shipped Android Version | Android 13                                       |


## Building

### Extract Vendor Blobs

The extract-files.sh script requires LineageOS extract-utils. Run this from within a LineageOS build environment:

```bash
./extract-files.sh
```

Alternatively, extract from stock ROM images. Mount the vendor and odm partitions, then:

```bash
./extract-files.sh /path/to/mounted/stock
```

### Build LineageOS

Initialize the LineageOS source repository:

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs
```

Sync the repository:

```bash
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

Clone this device tree:

```bash
git clone https://github.com/none24-smu/android_device_oneplus_CPH2551.git device/oneplus/CPH2551
```

Clone kernel source:

```bash
git clone https://github.com/OnePlusOSS/android_kernel_common_oneplus_sm8550.git \
    -b oneplus/sm8550_v_15.0.0_oneplus_open kernel/oneplus/sm8550
```

Clone vendor blobs:

```bash
git clone https://github.com/none24-smu/android_vendor_oneplus_CPH2551.git vendor/oneplus/CPH2551
```

### Build

```bash
source build/envsetup.sh
lunch lineage_CPH2551-userdebug
mka bacon -j$(nproc --all)
```


## Copyright

```
#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
```
