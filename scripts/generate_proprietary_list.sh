#!/bin/bash
#
# Script to generate proprietary-files.txt from connected device
# Analyzes vendor partition and creates comprehensive blob list
#

set -e

DEVICE_TREE="/media/smuserverv1/SSD RAID/android_device_oneplus_CPH2551"
OUTPUT_FILE="$DEVICE_TREE/proprietary-files.txt"

echo "Generating proprietary files list from device..."
echo ""

# Check device connection
if ! adb get-state 2>/dev/null | grep -q "device"; then
    echo "Error: No device connected via ADB"
    exit 1
fi

# Create header
cat > "$OUTPUT_FILE" << 'EOF'
# Proprietary files for OnePlus CPH2551
# Extracted from stock Android 15 firmware

# Audio
EOF

# Audio HALs and libraries
echo "Scanning audio components..."
adb shell "find /vendor/lib64 -name '*audio*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/lib -name '*audio*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/etc -name '*audio*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Camera" >> "$OUTPUT_FILE"

# Camera HALs
echo "Scanning camera components..."
adb shell "find /vendor/lib64 -name '*camera*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/lib -name '*camera*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/etc -path '*/camera/*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Display & Graphics" >> "$OUTPUT_FILE"

# Graphics libs
echo "Scanning graphics components..."
adb shell "find /vendor/lib64/egl -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/lib/egl -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/lib64 -name '*vulkan*' -o -name '*gfx*' -o -name '*gpu*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Sensors" >> "$OUTPUT_FILE"

# Sensors
echo "Scanning sensor components..."
adb shell "find /vendor/lib64 -name '*sensor*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/lib -name '*sensor*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/etc/sensors -type f 2>/dev/null | sort" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# Bluetooth" >> "$OUTPUT_FILE"

# Bluetooth
echo "Scanning Bluetooth components..."
adb shell "find /vendor/lib64 -name '*bluetooth*' -type f | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/bin/hw -name '*bluetooth*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/etc/bluetooth -type f 2>/dev/null | sort" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# WiFi" >> "$OUTPUT_FILE"

# WiFi
echo "Scanning WiFi components..."
adb shell "find /vendor/bin -name '*wpa*' -o -name '*hostapd*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/etc/wifi -type f 2>/dev/null | sort" | sed 's|^/||' >> "$OUTPUT_FILE" || true
adb shell "find /vendor/firmware -name '*wifi*' -o -name '*wlan*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# RIL / Telephony" >> "$OUTPUT_FILE"

# RIL
echo "Scanning RIL/telephony components..."
adb shell "find /vendor/lib64 -name '*ril*' -o -name '*radio*' -o -name '*qti*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/bin -name '*netmgr*' -o -name '*qti*' -o -name '*ril*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# Fingerprint" >> "$OUTPUT_FILE"

# Biometrics
echo "Scanning biometric components..."
adb shell "find /vendor/lib64 -name '*fingerprint*' -o -name '*fpc*' -o -name '*goodix*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "# DRM & Media" >> "$OUTPUT_FILE"

# DRM
echo "Scanning DRM/media components..."
adb shell "find /vendor/lib64 -name '*drm*' -o -name '*mediadrm*' | sort" | sed 's|^/||' >> "$OUTPUT_FILE"
adb shell "find /vendor/lib64/mediadrm -type f 2>/dev/null | sort" | sed 's|^/||' >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "# Firmware" >> "$OUTPUT_FILE"

# Firmware files
echo "Scanning firmware..."
adb shell "find /vendor/firmware -type f | head -100 | sort" | sed 's|^/||' >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "✓ Generated: $OUTPUT_FILE"
echo ""
echo "Total files: $(grep -v '^#' "$OUTPUT_FILE" | grep -v '^$' | wc -l)"
echo ""
echo "Review the file and remove any duplicates or unnecessary entries."
echo "Then run: ./extract-files.sh"
