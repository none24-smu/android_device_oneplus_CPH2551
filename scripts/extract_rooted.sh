#!/bin/bash
#
# Improved rooted extraction using temp directory
#

set -e

DEVICE_TREE="/media/smuserverv1/SSD RAID/android_device_oneplus_CPH2551"
VENDOR_DIR="/media/smuserverv1/SSD RAID/vendor_oneplus_CPH2551"
PROP_FILE="$DEVICE_TREE/proprietary-files.txt"
TEMP_DIR="/sdcard/vendor_extract"

echo "================================================"
echo " Vendor Blob Extraction for OnePlus CPH2551"
echo " (Rooted - Improved Method)"
echo "================================================"
echo ""

# Check root
if ! adb shell "su -c 'whoami'" 2>/dev/null | grep -q "root"; then
    echo "Error: Root access required"
    exit 1
fi

echo "✓ Root access confirmed"
echo ""

# Create temp directory on device
echo "Setting up temp directory on device..."
adb shell "su -c 'rm -rf $TEMP_DIR && mkdir -p $TEMP_DIR && chmod 777 $TEMP_DIR'"

# Create vendor directory
mkdir -p "$VENDOR_DIR/proprietary"

# Extract files
TOTAL=$(grep -v '^#' "$PROP_FILE" | grep -v '^$' | wc -l)
COUNT=0
SUCCESS=0
FAILED=0

echo "Extracting $TOTAL files..."
echo ""

while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    COUNT=$((COUNT + 1))
    
    if [ $((COUNT % 100)) -eq 0 ]; then
        echo "[$COUNT/$TOTAL] Extracted: $SUCCESS | Failed: $FAILED"
    fi
    
    # Create local directory structure
    dir=$(dirname "$line")
    mkdir -p "$VENDOR_DIR/proprietary/$dir"
    
    # Get filename
    filename=$(basename "$line")
    
    # Copy file to temp with root, change permissions, then pull
    if adb shell "su -c 'cp /$line $TEMP_DIR/$filename && chmod 644 $TEMP_DIR/$filename'" 2>/dev/null; then
        if adb pull "$TEMP_DIR/$filename" "$VENDOR_DIR/proprietary/$line" 2>/dev/null; then
            SUCCESS=$((SUCCESS + 1))
            adb shell "rm $TEMP_DIR/$filename" 2>/dev/null
        else
            FAILED=$((FAILED + 1))
        fi
    else
        FAILED=$((FAILED + 1))
    fi
    
done < <(grep -v '^#' "$PROP_FILE" | grep -v '^$')

# Cleanup
adb shell "su -c 'rm -rf $TEMP_DIR'" 2>/dev/null

echo ""
echo "================================================"
echo "✓ Extraction Complete!"
echo "================================================"
echo "Total files processed: $COUNT"
echo "Successfully extracted: $SUCCESS"
echo "Failed: $FAILED"
echo ""
echo "Files location: $VENDOR_DIR/proprietary"
echo ""
echo "Next: Run setup-makefiles.sh to generate vendor makefiles"
