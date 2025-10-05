#!/bin/bash
#
# Simple ADB blob extractor
# Pulls vendor files directly from connected device
#

set -e

DEVICE_TREE="/media/smuserserv1/SSD RAID/android_device_oneplus_CPH2551"
VENDOR_DIR="/media/smuserverv1/SSD RAID/vendor_oneplus_CPH2551"
PROP_FILE="$DEVICE_TREE/proprietary-files.txt"

echo "================================================"
echo " Vendor Blob Extraction for OnePlus CPH2551"
echo "================================================"
echo ""

# Check ADB connection
if ! adb get-state 2>/dev/null | grep -q "device"; then
    echo "Error: No device connected"
    exit 1
fi

# Create vendor directories
echo "Creating vendor directory structure..."
mkdir -p "$VENDOR_DIR/proprietary"

# Extract files
echo "Extracting files from device..."
TOTAL=$(grep -v '^#' "$PROP_FILE" | grep -v '^$' | wc -l)
COUNT=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    COUNT=$((COUNT + 1))
    echo -ne "\r[$COUNT/$TOTAL] Extracting files...  "
    
    # Create directory structure
    dir=$(dirname "$line")
    mkdir -p "$VENDOR_DIR/proprietary/$dir"
    
    # Pull file from device
    adb pull "/$line" "$VENDOR_DIR/proprietary/$line" 2>/dev/null || {
        echo -e "\n⚠ Warning: Failed to pull /$line"
    }
    
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
