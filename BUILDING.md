# Complete Device Tree Building Checklist for OnePlus CPH2551
## LineageOS 22.2 Build Guide

This comprehensive checklist covers everything needed to create a fully functional device tree.

---

## 📋 Phase 1: Kernel Setup

### ✅ Task 1: Clone and Configure Kernel Source

**Location:** `kernel/oneplus/sm8550`

**Steps:**
1. Clone the official OnePlus kernel source:
   ```bash
   git clone https://github.com/OnePlusOSS/android_kernel_common_oneplus_sm8550.git -b oneplus/sm8550_v_15.0.0_oneplus_open kernel/oneplus/sm8550
   ```

2. Identify the correct defconfig:
   - Check `arch/arm64/configs/` for device-specific config
   - Likely: `vendor/kalama-qgki_defconfig` or similar

3. Verify kernel version and dependencies:
   - Check kernel version (should be 5.15+)
   - Verify required modules are enabled

4. Test kernel compilation:
   ```bash
   export ARCH=arm64
   export CROSS_COMPILE=aarch64-linux-android-
   make vendor/kalama-qgki_defconfig
   make -j$(nproc)
   ```

**Files to Create:**
- `BoardConfig.mk` - Update `TARGET_KERNEL_CONFIG` and `TARGET_KERNEL_SOURCE`

---

## 📋 Phase 2: Stock ROM Analysis & Extraction

### ✅ Task 2: Extract and Analyze Stock ROM

**Location:** `/media/smuserverv1/SSD RAID/CPH2551 Android 15 Stock`

**Steps:**
1. Extract all images from stock ROM:
   ```bash
   # Install required tools
   sudo apt install android-tools-fsutils simg2img lpunpack

   # Extract super partition
   lpunpack super.img super_extracted/
   
   # Convert sparse images to raw
   simg2img system.img system_raw.img
   simg2img vendor.img vendor_raw.img
   simg2img product.img product_raw.img
   simg2img odm.img odm_raw.img
   
   # Mount images
   mkdir -p mnt/{system,vendor,product,odm}
   sudo mount -o ro,loop system_raw.img mnt/system
   sudo mount -o ro,loop vendor_raw.img mnt/vendor
   sudo mount -o ro,loop product_raw.img mnt/product
   sudo mount -o ro,loop odm_raw.img mnt/odm
   ```

2. Analyze partition layout:
   - Check `super.img` structure
   - Verify partition sizes match `BoardConfig.mk`
   - Document dynamic partition configuration

3. Extract important files:
   - Kernel: `boot.img`, `vendor_boot.img`
   - Device tree blobs: `dtb`, `dtbo`
   - Firmware files

**Files to Update:**
- `BoardConfig.mk` - Partition sizes
- `fstab.qcom` - Mount points and filesystems

---

## 📋 Phase 3: Vendor Blob Extraction

### ✅ Task 3: Create Vendor Blob List and Extract

**Location:** `device/oneplus/CPH2551/proprietary-files.txt`

**Steps:**
1. Identify required proprietary libraries:
   - Camera HALs: `vendor/lib64/camera.*`, `vendor/lib64/hw/camera.*`
   - Audio HALs: `vendor/lib/hw/audio.*`, `vendor/lib/soundfx/*`
   - Graphics: `vendor/lib64/egl/*`, `vendor/lib64/hw/vulkan.*`
   - Sensors: `vendor/lib64/hw/sensors.*`, `vendor/lib64/sensors.*`
   - Radio/RIL: `vendor/lib64/*ril*`, `vendor/bin/qti`
   - Bluetooth: `vendor/lib64/hw/bluetooth.*`, `vendor/bin/hw/android.hardware.bluetooth*`
   - WiFi: `vendor/bin/hw/wpa_supplicant`, `vendor/etc/wifi/*`
   - Fingerprint: `vendor/lib64/hw/*fingerprint*`
   - DRM: `vendor/lib64/*drm*`, `vendor/lib64/mediadrm/*`

2. Create comprehensive `proprietary-files.txt`:
   ```bash
   # Reference from mounted stock ROM
   find mnt/vendor -type f | grep -E "\.(so|xml|bin)$" > vendor_files.txt
   ```

3. Extract vendor blobs:
   ```bash
   cd device/oneplus/CPH2551
   ./extract-files.sh /media/smuserverv1/SSD\ RAID/CPH2551\ Android\ 15\ Stock/
   ```

**Files to Create:**
- `proprietary-files.txt` - Complete blob list
- `vendor/oneplus/CPH2551/` - Vendor repository structure

---

## 📋 Phase 4: Init Scripts & Boot Configuration

### ✅ Task 4: Extract and Create Init Scripts

**Location:** `device/oneplus/CPH2551/rootdir/etc/`

**Steps:**
1. Extract init scripts from boot.img:
   ```bash
   # Unpack boot image
   unpack_bootimg --boot_img boot.img --out boot_extracted/
   
   # Extract ramdisk
   cd boot_extracted/
   gunzip -c ramdisk | cpio -i
   ```

2. Required init files:
   - `init.qcom.rc` - Main Qualcomm init script
   - `init.target.rc` - Device-specific init
   - `init.qcom.usb.rc` - USB configuration
   - `init.qcom.power.rc` - Power management
   - `ueventd.qcom.rc` - Device node permissions
   - `fstab.qcom` - Already created

3. Create init service files:
   - Platform-specific services
   - Hardware initialization sequences
   - Firmware loading scripts

**Files to Create:**
- `rootdir/etc/init.qcom.rc`
- `rootdir/etc/init.target.rc`
- `rootdir/etc/init.qcom.usb.rc`
- `rootdir/etc/ueventd.qcom.rc`

**Update:**
- `device.mk` - Add `PRODUCT_COPY_FILES` for init scripts

---

## 📋 Phase 5: Audio Configuration

### ✅ Task 5: Configure Audio System

**Location:** `device/oneplus/CPH2551/configs/audio/`

**Steps:**
1. Extract audio configuration files from vendor:
   - `audio_policy_configuration.xml`
   - `audio_effects.xml`
   - `mixer_paths.xml` (device-specific mixer controls)
   - `audio_platform_info.xml`
   - `sound_trigger_platform_info.xml`
   - `audio_tuning_mixer.txt`

2. Copy from stock vendor:
   ```bash
   cp mnt/vendor/etc/audio/* device/oneplus/CPH2551/configs/audio/
   ```

3. Configure audio HAL in device.mk:
   ```makefile
   PRODUCT_PACKAGES += \
       android.hardware.audio@7.1-impl \
       android.hardware.audio.effect@7.0-impl
   ```

**Files to Create:**
- `configs/audio/audio_policy_configuration.xml`
- `configs/audio/mixer_paths.xml`
- `configs/audio/audio_platform_info.xml`

**Update:**
- `device.mk` - Audio packages and copy files
- `BoardConfig.mk` - Audio flags

---

## 📋 Phase 6: Camera Configuration

### ✅ Task 6: Setup Camera HAL

**Location:** `device/oneplus/CPH2551/configs/camera/`

**Steps:**
1. Extract camera configuration files:
   - `camera_config.xml`
   - Camera HAL libraries
   - Camera sensor configs

2. Identify camera sensors from stock:
   ```bash
   grep -r "camera" mnt/vendor/etc/
   ```

3. Configure camera HAL:
   - Multiple camera support (main, ultrawide, telephoto, front)
   - Camera API2 support
   - Vendor-specific extensions

**Files to Create:**
- `configs/camera/camera_config.xml`

**Update:**
- `device.mk` - Camera packages
- `product.prop` - Camera properties

---

## 📋 Phase 7: Display & Graphics

### ✅ Task 7: Configure Display and Graphics

**Location:** `device/oneplus/CPH2551/`

**Steps:**
1. Extract display configuration:
   - Display panel configs
   - HDR capabilities
   - High refresh rate settings (120Hz support)

2. Configure graphics properties:
   ```properties
   # product.prop or vendor.prop
   ro.surface_flinger.has_HDR_display=true
   ro.surface_flinger.has_wide_color_display=true
   ro.surface_flinger.use_color_management=true
   ro.surface_flinger.max_frame_buffer_acquired_buffers=3
   ```

3. Configure display density:
   - Verify LCD density in `product.prop`

**Update:**
- `product.prop` - Display properties
- `vendor.prop` - Graphics properties
- `BoardConfig.mk` - Display flags

---

## 📋 Phase 8: Sensors Configuration

### ✅ Task 8: Configure Sensor HAL

**Location:** `device/oneplus/CPH2551/configs/sensors/`

**Steps:**
1. Extract sensor configuration:
   - `sns_reg_config` files
   - Sensor calibration data
   - Sensor list configuration

2. Identify available sensors:
   - Accelerometer
   - Gyroscope
   - Magnetometer
   - Light sensor
   - Proximity sensor
   - Hall sensor

3. Copy sensor configs from vendor:
   ```bash
   cp -r mnt/vendor/etc/sensors/ device/oneplus/CPH2551/configs/
   ```

**Files to Create:**
- `configs/sensors/hals.conf`

**Update:**
- `device.mk` - Sensor packages
- `vendor.prop` - Sensor properties

---

## 📋 Phase 9: Bluetooth & WiFi

### ✅ Task 9: Configure Wireless Connectivity

**Location:** `device/oneplus/CPH2551/configs/`

**Steps:**
1. Extract WiFi configuration:
   - `WCNSS_qcom_cfg.ini`
   - `wpa_supplicant` overlay
   - `p2p_supplicant` overlay
   - WiFi firmware files

2. Extract Bluetooth firmware:
   - Copy from `mnt/vendor/firmware/` or `mnt/vendor/bt_firmware/`

3. Configure WiFi HAL:
   ```bash
   cp mnt/vendor/etc/wifi/* device/oneplus/CPH2551/configs/wifi/
   ```

**Files to Create:**
- `configs/wifi/WCNSS_qcom_cfg.ini`
- `configs/wifi/wpa_supplicant_overlay.conf`
- `configs/wifi/p2p_supplicant_overlay.conf`

**Update:**
- `device.mk` - WiFi & Bluetooth packages
- `BoardConfig.mk` - WiFi driver configuration

---

## 📋 Phase 10: RIL/Telephony

### ✅ Task 10: Configure Radio Interface Layer

**Location:** `device/oneplus/CPH2551/`

**Steps:**
1. Extract RIL libraries and configurations:
   - QTI radio HAL
   - IMS configurations
   - APN configurations

2. Configure telephony properties:
   - Network modes
   - IMS settings
   - VoLTE/VoWiFi support

3. Extract from vendor:
   ```bash
   find mnt/vendor -name "*ril*" -o -name "*radio*" -o -name "*qti*"
   ```

**Update:**
- `proprietary-files.txt` - RIL libraries
- `system.prop` - Radio properties
- `vendor.prop` - RIL configurations

---

## 📋 Phase 11: NFC Configuration

### ✅ Task 11: Setup NFC (if applicable)

**Location:** `device/oneplus/CPH2551/configs/nfc/`

**Steps:**
1. Verify NFC hardware presence:
   ```bash
   find mnt/vendor -name "*nfc*"
   ```

2. Extract NFC configuration:
   - `libnfc-nci.conf`
   - NFC firmware
   - NFC HAL

3. Configure NFC in device.mk

**Files to Create:**
- `configs/nfc/libnfc-nci.conf`

**Update:**
- `device.mk` - NFC packages
- `product.prop` - NFC port configuration

---

## 📋 Phase 12: Biometrics

### ✅ Task 12: Configure Fingerprint/Face Unlock

**Location:** `device/oneplus/CPH2551/`

**Steps:**
1. Extract fingerprint HAL:
   - Identify fingerprint sensor vendor (FPC, Goodix, Egis)
   - Extract HAL libraries

2. Configure biometric properties:
   ```bash
   grep -r "fingerprint" mnt/vendor/
   ```

3. Setup permissions and SELinux contexts

**Update:**
- `proprietary-files.txt` - Biometric HALs
- `product.prop` - Hardware fingerprint property
- `device.mk` - Biometric packages

---

## 📋 Phase 13: Power & Charging

### ✅ Task 13: Configure Power Management

**Location:** `device/oneplus/CPH2551/configs/power/`

**Steps:**
1. Extract power HAL configuration:
   - Power profiles
   - CPU governor settings
   - Thermal engine configs

2. Configure charging parameters:
   - Fast charging support
   - Battery capacity
   - Thermal limits

3. Copy power configs:
   ```bash
   cp mnt/vendor/etc/powerhint.xml device/oneplus/CPH2551/configs/power/
   ```

**Files to Create:**
- `configs/power/powerhint.xml`

**Update:**
- `device.mk` - Power HAL packages
- `BoardConfig.mk` - Power flags

---

## 📋 Phase 14: Permissions

### ✅ Task 14: Create Permission Files

**Location:** `device/oneplus/CPH2551/configs/permissions/`

**Steps:**
1. Create privapp permission files:
   - System app permissions
   - Privileged app permissions

2. Create hardware feature declarations:
   ```xml
   <!-- handheld_core_hardware.xml -->
   <feature name="android.hardware.bluetooth" />
   <feature name="android.hardware.camera" />
   <feature name="android.hardware.location" />
   <feature name="android.hardware.sensor.accelerometer" />
   <feature name="android.hardware.sensor.compass" />
   <feature name="android.hardware.sensor.gyroscope" />
   <feature name="android.hardware.sensor.light" />
   <feature name="android.hardware.sensor.proximity" />
   <feature name="android.hardware.telephony.gsm" />
   <feature name="android.hardware.touchscreen" />
   <feature name="android.hardware.usb.accessory" />
   <feature name="android.hardware.wifi" />
   ```

**Files to Create:**
- `configs/permissions/privapp-permissions-oneplus.xml`
- `configs/permissions/handheld_core_hardware.xml`

**Update:**
- `device.mk` - Copy permission files

---

## 📋 Phase 15: SELinux Policies

### ✅ Task 15: Create SELinux Policies

**Location:** `device/oneplus/CPH2551/sepolicy/`

**Steps:**
1. Create sepolicy directory structure:
   ```bash
   mkdir -p device/oneplus/CPH2551/sepolicy/{vendor,private}
   ```

2. Extract and analyze stock sepolicy:
   ```bash
   # From stock vendor
   cp -r mnt/vendor/etc/selinux/* device/oneplus/CPH2551/sepolicy/vendor/
   ```

3. Create device-specific policy files:
   - `file_contexts` - File security contexts
   - `device.te` - Device type enforcement
   - `hal_*.te` - HAL policies
   - `property_contexts` - Property security contexts

4. Test for denials:
   - Boot device
   - Check `dmesg` and `logcat` for `avc: denied`
   - Add policies to fix denials

**Files to Create:**
- `sepolicy/vendor/file_contexts`
- `sepolicy/vendor/genfs_contexts`
- `sepolicy/vendor/property_contexts`
- `sepolicy/vendor/*.te` files

**Update:**
- `BoardConfig.mk` - Add `BOARD_SEPOLICY_DIRS`

---

## 📋 Phase 16: Overlays

### ✅ Task 16: Create Framework & SystemUI Overlays

**Location:** `device/oneplus/CPH2551/overlay/`

**Steps:**
1. Create overlay structure:
   ```bash
   mkdir -p device/oneplus/CPH2551/overlay/frameworks/base/core/res/res/values
   mkdir -p device/oneplus/CPH2551/overlay/frameworks/base/packages/SystemUI/res/values
   ```

2. Create overlay files:
   - `config.xml` - Framework configuration overrides
   - `dimens.xml` - Dimension overrides (status bar, nav bar)
   - `strings.xml` - String overrides
   - `arrays.xml` - Array overrides (WiFi, Bluetooth)

3. Device-specific overlays:
   - Display cutout configuration
   - Rounded corner radius
   - Button configurations
   - Battery capacity

**Files to Create:**
- `overlay/frameworks/base/core/res/res/values/config.xml`
- `overlay/frameworks/base/core/res/res/values/dimens.xml`
- `overlay/AndroidManifest.xml`

**Update:**
- `device.mk` - Add `DEVICE_PACKAGE_OVERLAYS`

---

## 📋 Phase 17: Partition Configuration

### ✅ Task 17: Verify Partition Layout

**Location:** `device/oneplus/CPH2551/BoardConfig.mk`

**Steps:**
1. Extract partition information from stock:
   ```bash
   # From device
   adb shell cat /proc/partitions
   adb shell ls -la /dev/block/bootdevice/by-name/
   ```

2. Verify partition sizes:
   - Boot partition
   - Vendor boot partition
   - Super partition (dynamic partitions)
   - Userdata partition
   - Metadata partition

3. Update BoardConfig.mk with correct sizes

**Update:**
- `BoardConfig.mk` - All partition sizes

---

## 📋 Phase 18: Recovery Configuration

### ✅ Task 18: Setup Recovery

**Location:** `device/oneplus/CPH2551/recovery/`

**Steps:**
1. Configure recovery options:
   - Screen resolution
   - Touch driver
   - Decryption support

2. Create recovery fstab if different from main fstab

3. Test recovery boot:
   ```bash
   adb reboot recovery
   ```

**Files to Create:**
- `recovery/root/init.recovery.qcom.rc`

**Update:**
- `BoardConfig.mk` - Recovery flags
- `device.mk` - Recovery packages

---

## 📋 Phase 19: Vendor Repository

### ✅ Task 19: Create Vendor Repository

**Location:** `vendor/oneplus/CPH2551/`

**Steps:**
1. Run setup-makefiles.sh:
   ```bash
   cd device/oneplus/CPH2551
   ./setup-makefiles.sh
   ```

2. Create vendor repository structure:
   ```
   vendor/oneplus/CPH2551/
   ├── Android.mk
   ├── BoardConfigVendor.mk
   ├── CPH2551-vendor.mk
   └── proprietary/
   ```

3. Push vendor repository to GitHub:
   ```bash
   cd vendor/oneplus/CPH2551
   git init
   git checkout -b lineage-22.2
   git add .
   git commit -m "Initial vendor blobs for OnePlus CPH2551"
   git remote add origin https://github.com/none24-smu/android_vendor_oneplus_CPH2551.git
   git push -u origin lineage-22.2
   ```

---

## 📋 Phase 20: Testing & Debugging

### ✅ Task 20: Build, Test, and Debug

**Steps:**
1. Initial build attempt:
   ```bash
   source build/envsetup.sh
   lunch lineage_CPH2551-userdebug
   mka bacon -j$(nproc)
   ```

2. Address build errors:
   - Missing dependencies
   - Incorrect paths
   - Syntax errors

3. Flash and test:
   ```bash
   adb reboot bootloader
   fastboot flash boot boot.img
   fastboot flash vendor_boot vendor_boot.img
   fastboot flash super super_empty.img
   fastboot flash super lineage-*.img
   fastboot reboot
   ```

4. Debug boot issues:
   - Check `adb logcat`
   - Check `dmesg`
   - Monitor SELinux denials
   - Test each hardware component

5. Hardware testing checklist:
   - [ ] Boot to system
   - [ ] Display & touch
   - [ ] WiFi connectivity
   - [ ] Bluetooth
   - [ ] Mobile data (SIM)
   - [ ] Phone calls
   - [ ] SMS
   - [ ] Camera (all lenses)
   - [ ] Audio (speaker, mic, headphones)
   - [ ] Sensors (accelerometer, gyro, light, proximity)
   - [ ] Fingerprint
   - [ ] Charging
   - [ ] USB connectivity (ADB, MTP)
   - [ ] GPS
   - [ ] NFC (if applicable)

---

## 🔧 Additional Resources

### Useful Commands:
```bash
# Extract boot image
unpack_bootimg --boot_img boot.img --out boot_out/

# Unpack system image
lpunpack super.img super_output/

# Monitor logs
adb logcat | grep -i "error\|denied\|fail"

# Check SELinux denials
adb shell dmesg | grep -i "avc.*denied"

# Get device properties
adb shell getprop | grep -E "ro.product|ro.build|ro.board"
```

### Reference Documentation:
- [LineageOS Wiki](https://wiki.lineageos.org/devices/)
- [Android Device Tree Guide](https://source.android.com/docs/core/architecture/bootloader)
- [Qualcomm HAL Documentation](https://source.codeaurora.org/)

---

## 📝 Notes

- Always backup original stock ROM before testing
- Keep detailed notes of changes and fixes
- Test thoroughly before public release
- Document known issues in README.md

**Good luck with your LineageOS 22.2 device tree!** 🚀
