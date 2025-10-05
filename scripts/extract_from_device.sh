#!/bin/bash
#
# Rooted ADB blob extractor
# Pulls vendor files from device with root access
#

set -e

DEVICE_TREE="/media/smuserverv1/SSD RAID/android_device_oneplus_CPH2551"
VENDOR_DIR="/media/smuserverv1/SSD RAID/vendor_oneplus_CPH2551"
PROP_FILE="$DEVICE_TREE/proprietary-files.txt"

echo "================================================"
echo " Vendor Blob Extraction for OnePlus CPH2551"
echo " (Rooted Device)"
echo "================================================"
echo ""

# Check ADB connection
if ! adb get-state 2>/dev/null | grep -q "device"; then
    echo "Error: No device connected"
    exit 1
fi

# Check root access
if ! adb shell "su -c 'whoami'" 2>/dev/null | grep -q "root"; then
    echo "Error: Root access required"
    exit 1
fi

echo "✓ Root access confirmed"
echo ""

# Create vendor directories
echo "Creating vendor directory structure..."
mkdir -p "$VENDOR_DIR/proprietary"

# Extract files
echo "Extracting files from device..."
TOTAL=$(grep -v '^#' "$PROP_FILE" | grep -v '^$' | wc -l)
COUNT=0
FAILED=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    COUNT=$((COUNT + 1))
    
    # Show progress every 50 files
    if [ $((COUNT % 50)) -eq 0 ]; then
        echo "[$COUNT/$TOTAL] Extracting..."
    fi
    
    # Create directory structure
    dir=$(dirname "$line")
    mkdir -p "$VENDOR_DIR/proprietary/$dir"
    
    # Pull file from device with root
    if ! adb pull "/$line" "$VENDOR_DIR/proprietary/$line" 2>/dev/null; then
        # Try with su if normal pull fails
        adb shell "su -c 'cat /$line'" > "$VENDOR_DIR/proprietary/$line" 2>/dev/null || {
            FAILED=$((FAILED + 1))
        }
    fi
    
done < <(grep -v '^#' "$PROP_FILE" | grep -v '^$')

echo -e "\n\n✓ Extraction complete!"
echo ""
echo "Files extracted to: $VENDOR_DIR/proprietary"
echo "Total files: $COUNT"
echo ""
echo "Next steps:"
echo "1. Review extracted files"
echo "2. Run setup-makefiles.sh to generate vendor makefiles"
echo "3. Push to GitHub as vendor repository"
