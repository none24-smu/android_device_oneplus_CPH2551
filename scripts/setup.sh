#!/bin/bash
#
# Setup script for OnePlus CPH2551 device tree development
# This script helps prepare the environment for building LineageOS 22.2
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_DIR="$(dirname "$SCRIPT_DIR")"
STOCK_ROM_DIR="/media/smuserverv1/SSD RAID/CPH2551 Android 15 Stock"
EXTRACTED_DIR="/media/smuserverv1/SSD RAID/CPH2551_extracted"

echo "========================================="
echo "OnePlus CPH2551 Device Tree Setup"
echo "LineageOS 22.2"
echo "========================================="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
echo "[1/5] Checking required tools..."
MISSING_TOOLS=()

if ! command_exists python3; then
    MISSING_TOOLS+=("python3")
fi

if ! command_exists git; then
    MISSING_TOOLS+=("git")
fi

if ! command_exists adb; then
    MISSING_TOOLS+=("adb")
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "Missing required tools: ${MISSING_TOOLS[*]}"
    echo "Please install them first:"
    echo "  sudo apt install python3 git android-tools-adb android-tools-fastboot"
    exit 1
fi

echo "✓ All required tools found"
echo ""

# Clone payload dumper if not exists
echo "[2/5] Setting up payload dumper..."
if [ ! -d "$EXTRACTED_DIR/payload_dumper" ]; then
    echo "Cloning payload_dumper-go..."
    mkdir -p "$EXTRACTED_DIR"
    cd "$EXTRACTED_DIR"
    
    # Check if Go is installed
    if command_exists go; then
        git clone https://github.com/ssut/payload-dumper-go.git payload_dumper
        cd payload_dumper
        go build
        echo "✓ payload_dumper-go built successfully"
    else
        echo "Go is not installed. Trying Python version..."
        git clone https://github.com/vm03/payload_dumper.git payload_dumper
        cd payload_dumper
        pip3 install -r requirements.txt
        echo "✓ payload_dumper (Python) installed"
    fi
else
    echo "✓ Payload dumper already exists"
fi
echo ""

# Extract payload.bin
echo "[3/5] Extracting payload.bin from stock ROM..."
if [ ! -d "$EXTRACTED_DIR/images" ]; then
    mkdir -p "$EXTRACTED_DIR/images"
    cd "$EXTRACTED_DIR/images"
    
    if [ -f "$EXTRACTED_DIR/payload_dumper/payload-dumper-go" ]; then
        "$EXTRACTED_DIR/payload_dumper/payload-dumper-go" -o . "$STOCK_ROM_DIR/payload.bin"
    else
        python3 "$EXTRACTED_DIR/payload_dumper/payload_dumper.py" "$STOCK_ROM_DIR/payload.bin"
    fi
    
    echo "✓ Payload extracted successfully"
else
    echo "✓ Images already extracted"
fi
echo ""

# Clone kernel source
echo "[4/5] Setting up kernel source..."
KERNEL_DIR="/media/smuserverv1/SSD RAID/kernel_oneplus_sm8550"
if [ ! -d "$KERNEL_DIR" ]; then
    echo "Cloning OnePlus SM8550 kernel source..."
    git clone https://github.com/OnePlusOSS/android_kernel_common_oneplus_sm8550.git \
        -b oneplus/sm8550_v_15.0.0_oneplus_open \
        "$KERNEL_DIR"
    echo "✓ Kernel source cloned"
else
    echo "✓ Kernel source already exists"
fi
echo ""

# Summary
echo "[5/5] Setup Summary"
echo "========================================="
echo "Device Tree: $DEVICE_DIR"
echo "Stock ROM: $STOCK_ROM_DIR"
echo "Extracted Images: $EXTRACTED_DIR/images"
echo "Kernel Source: $KERNEL_DIR"
echo ""
echo "Next Steps:"
echo "1. Review extracted images in: $EXTRACTED_DIR/images"
echo "2. Mount images to extract vendor blobs"
echo "3. Follow BUILDING.md for detailed instructions"
echo "4. Check TODO list in Cursor IDE"
echo ""
echo "To mount images, run:"
echo "  sudo ./scripts/mount_images.sh"
echo ""
echo "Setup complete! ✓"
echo "========================================="
