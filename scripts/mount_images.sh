#!/bin/bash
#
# Mount extracted stock ROM images for blob extraction
#

set -e

EXTRACTED_DIR="/media/smuserverv1/SSD RAID/CPH2551_extracted/images"
MOUNT_DIR="/media/smuserverv1/SSD RAID/CPH2551_mounted"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Mounting stock ROM images..."
echo ""

# Create mount directories
mkdir -p "$MOUNT_DIR"/{system,vendor,product,odm,system_ext}

# Function to mount image
mount_image() {
    local img_name=$1
    local mount_point=$2
    
    if [ -f "$EXTRACTED_DIR/${img_name}.img" ]; then
        echo "Mounting ${img_name}.img to ${mount_point}..."
        
        # Try to mount directly, if fails, it might be sparse
        if ! mount -o ro,loop "$EXTRACTED_DIR/${img_name}.img" "$mount_point" 2>/dev/null; then
            echo "  Converting sparse image to raw..."
            simg2img "$EXTRACTED_DIR/${img_name}.img" "$EXTRACTED_DIR/${img_name}_raw.img"
            mount -o ro,loop "$EXTRACTED_DIR/${img_name}_raw.img" "$mount_point"
        fi
        
        echo "  ✓ ${img_name} mounted at ${mount_point}"
    else
        echo "  ⚠ ${img_name}.img not found, skipping..."
    fi
}

# Mount all partitions
mount_image "system" "$MOUNT_DIR/system"
mount_image "vendor" "$MOUNT_DIR/vendor"
mount_image "product" "$MOUNT_DIR/product"
mount_image "odm" "$MOUNT_DIR/odm"
mount_image "system_ext" "$MOUNT_DIR/system_ext"

echo ""
echo "Images mounted successfully!"
echo "Mount point: $MOUNT_DIR"
echo ""
echo "To extract vendor blobs, run:"
echo "  cd /media/smuserverv1/SSD\\ RAID/android_device_oneplus_CPH2551"
echo "  ./extract-files.sh $MOUNT_DIR"
echo ""
echo "When done, unmount with:"
echo "  sudo ./scripts/umount_images.sh"
