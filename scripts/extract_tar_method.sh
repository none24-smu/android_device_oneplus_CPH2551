#!/bin/bash
#
# Efficient batch extraction using tar
#

set -e

DEVICE_TREE="/media/smuserverv1/SSD RAID/android_device_oneplus_CPH2551"
VENDOR_DIR="/media/smuserverv1/SSD RAID/vendor_oneplus_CPH2551"
PROP_FILE="$DEVICE_TREE/proprietary-files.txt"

echo "================================================"
echo " Vendor Blob Batch Extraction (TAR Method)"
echo " OnePlus CPH2551"
echo "================================================"
echo ""

# Check root
if ! adb shell "su -c 'whoami'" 2>/dev/null | grep -q "root"; then
    echo "Error: Root access required"
    exit 1
fi

echo "✓ Root access confirmed"

# Create vendor directory
mkdir -p "$VENDOR_DIR"

# Create file list on device
echo "Creating file list..."
adb shell "su -c 'cat > /sdcard/vendor_files.txt'" < <(grep -v '^#' "$PROP_FILE" | grep -v '^$' | sed 's|^|/|')

# Count files
TOTAL=$(grep -v '^#' "$PROP_FILE" | grep -v '^$' | wc -l)
echo "Files to extract: $TOTAL"
echo ""

# Create tar archive on device
echo "Creating archive on device (this may take a few minutes)..."
adb shell "su -c 'cd / && tar czf /sdcard/vendor_blobs.tar.gz -T /sdcard/vendor_files.txt 2>/dev/null'" && {
    echo "✓ Archive created"
    
    # Pull the archive
    echo "Pulling archive from device..."
    adb pull /sdcard/vendor_blobs.tar.gz /tmp/vendor_blobs.tar.gz
    
    # Extract locally
    echo "Extracting archive..."
    cd "$VENDOR_DIR"
    tar xzf /tmp/vendor_blobs.tar.gz
    
    # Cleanup
    echo "Cleaning up..."
    adb shell "rm /sdcard/vendor_blobs.tar.gz /sdcard/vendor_files.txt"
    rm /tmp/vendor_blobs.tar.gz
    
    echo ""
    echo "================================================"
    echo "✓ Extraction Complete!"
    echo "================================================"
    echo "Files extracted to: $VENDOR_DIR"
    echo ""
    
    # Count extracted files
    EXTRACTED=$(find "$VENDOR_DIR/vendor" -type f 2>/dev/null | wc -l)
    echo "Total files extracted: $EXTRACTED"
    
} || {
    echo "✗ Archive creation failed"
    echo "Falling back to individual file extraction..."
    adb shell "rm /sdcard/vendor_files.txt 2>/dev/null"
}
