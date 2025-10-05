#!/bin/bash
#
# Unmount stock ROM images
#

set -e

MOUNT_DIR="/media/smuserverv1/SSD RAID/CPH2551_mounted"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Unmounting stock ROM images..."

for dir in system vendor product odm system_ext; do
    if mountpoint -q "$MOUNT_DIR/$dir"; then
        echo "Unmounting $dir..."
        umount "$MOUNT_DIR/$dir"
        echo "  ✓ $dir unmounted"
    fi
done

echo ""
echo "All images unmounted successfully!"
