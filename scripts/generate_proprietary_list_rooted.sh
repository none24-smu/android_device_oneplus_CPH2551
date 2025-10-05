#!/bin/bash
#
# Complete vendor blob list generator with root access
# Extracts ALL vendor files including binaries, firmware, and configs
#

set -e

DEVICE_TREE="/media/smuserverv1/SSD RAID/android_device_oneplus_CPH2551"
OUTPUT_FILE="$DEVICE_TREE/proprietary-files.txt"

echo "================================================"
echo " Complete Vendor Blob Catalog (Rooted Device)"
echo "================================================"
echo ""

# Check root access
if ! adb shell "su -c 'whoami'" 2>/dev/null | grep -q "root"; then
    echo "Error: Root access not available"
    exit 1
fi

echo "✓ Root access confirmed"
echo "Scanning vendor partition comprehensively..."
echo ""

# Create header
cat > "$OUTPUT_FILE" << 'EOF'
# Proprietary files for OnePlus CPH2551
# Extracted from stock Android 15 firmware (rooted extraction)

# Audio
EOF

# Audio HALs, configs, and binaries
echo "[1/15] Audio components..."
adb shell "su -c 'find /vendor/lib64 -name \"*audio*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/lib -name \"*audio*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/etc -name \"*audio*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Camera" >> "$OUTPUT_FILE"

# Camera HALs and binaries
echo "[2/15] Camera components..."
adb shell "su -c 'find /vendor/lib64 -name \"*camera*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/lib -name \"*camera*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/bin/hw -name \"*camera*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/etc -path \"*/camera/*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Display & Graphics" >> "$OUTPUT_FILE"

# Graphics libs and display configs
echo "[3/15] Display & Graphics..."
adb shell "su -c 'find /vendor/lib64/egl -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/lib/egl -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/lib64 -name \"*vulkan*\" -o -name \"*gfx*\" -o -name \"*gpu*\" -o -name \"*adreno*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/bin/hw -name \"*display*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Sensors" >> "$OUTPUT_FILE"

# Sensors
echo "[4/15] Sensor components..."
adb shell "su -c 'find /vendor/lib64 -name \"*sensor*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/lib -name \"*sensor*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/bin/hw -name \"*sensor*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/etc/sensors -type f 2>/dev/null | sort'" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# Bluetooth" >> "$OUTPUT_FILE"

# Bluetooth
echo "[5/15] Bluetooth components..."
adb shell "su -c 'find /vendor/lib64 -name \"*bluetooth*\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/bin/hw -name \"*bluetooth*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/etc/bluetooth -type f 2>/dev/null | sort'" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# WiFi" >> "$OUTPUT_FILE"

# WiFi
echo "[6/15] WiFi components..."
adb shell "su -c 'find /vendor/bin/hw -name \"*wpa*\" -o -name \"*hostapd*\" -o -name \"*wifi*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/etc/wifi -type f 2>/dev/null | sort'" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# RIL / Telephony" >> "$OUTPUT_FILE"

# RIL
echo "[7/15] RIL/Telephony..."
adb shell "su -c 'find /vendor/lib64 -name \"*ril*\" -o -name \"*radio*\" -o -name \"*qti*\" -o -name \"*qcril*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/bin -name \"*netmgr*\" -o -name \"qcril*\" -o -name \"*ril*\" -o -name \"*ims*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Fingerprint / Biometrics" >> "$OUTPUT_FILE"

# Biometrics
echo "[8/15] Biometric components..."
adb shell "su -c 'find /vendor/lib64 -name \"*fingerprint*\" -o -name \"*fpc*\" -o -name \"*goodix*\" -o -name \"*egis*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# DRM & Media" >> "$OUTPUT_FILE"

# DRM
echo "[9/15] DRM/Media..."
adb shell "su -c 'find /vendor/lib64 -name \"*drm*\" -o -name \"*mediadrm*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/bin/hw -name \"*drm*\" -o -name \"*media*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Thermal & Power" >> "$OUTPUT_FILE"

# Thermal
echo "[10/15] Thermal/Power..."
adb shell "su -c 'find /vendor/bin/hw -name \"*thermal*\" -o -name \"*power*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "su -c 'find /vendor/etc -name \"*thermal*\" -o -name \"*power*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Peripheral HALs" >> "$OUTPUT_FILE"

# Other HALs
echo "[11/15] Peripheral HALs..."
adb shell "su -c 'find /vendor/bin/hw -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Libraries" >> "$OUTPUT_FILE"

# Additional important libraries
echo "[12/15] Core libraries..."
adb shell "su -c 'find /vendor/lib64 -name \"*.so\" -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Configuration Files" >> "$OUTPUT_FILE"

# Config files
echo "[13/15] Configuration files..."
adb shell "su -c 'find /vendor/etc -type f -name \"*.xml\" -o -name \"*.conf\" -o -name \"*.txt\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Firmware" >> "$OUTPUT_FILE"

# Firmware files
echo "[14/15] Firmware files..."
adb shell "su -c 'find /vendor/firmware -type f | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Executables" >> "$OUTPUT_FILE"

# Vendor binaries
echo "[15/15] Vendor executables..."
adb shell "su -c 'find /vendor/bin -type f ! -path \"*/hw/*\" | sort'" | sed 's|^/||' >> "$OUTPUT_FILE"

echo ""
echo "✓ Complete catalog generated: $OUTPUT_FILE"
echo ""

# Count and summary
TOTAL=$(grep -v '^#' "$OUTPUT_FILE" | grep -v '^$' | wc -l)
echo "Total proprietary files: $TOTAL"
echo ""
echo "Summary by category:"
echo "  Audio:       $(grep -c 'audio' "$OUTPUT_FILE" || echo 0)"
echo "  Camera:      $(grep -c 'camera' "$OUTPUT_FILE" || echo 0)"
echo "  Graphics:    $(grep -c 'egl\|vulkan\|gpu\|adreno' "$OUTPUT_FILE" || echo 0)"
echo "  Sensors:     $(grep -c 'sensor' "$OUTPUT_FILE" || echo 0)"
echo "  Bluetooth:   $(grep -c 'bluetooth' "$OUTPUT_FILE" || echo 0)"
echo "  WiFi:        $(grep -c 'wifi\|wpa\|hostapd' "$OUTPUT_FILE" || echo 0)"
echo "  RIL:         $(grep -c 'ril\|radio\|qcril' "$OUTPUT_FILE" || echo 0)"
echo "  Firmware:    $(grep -c 'firmware' "$OUTPUT_FILE" || echo 0)"
echo ""
echo "Ready for extraction! Run: ./scripts/extract_from_device.sh"
