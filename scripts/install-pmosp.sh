#!/usr/bin/env bash
# postmarketOS OnePlus 6 Installation Script
# Prerequisite: pmbootstrap must be installed on your Linux machine
# (pmbootstrap does NOT support macOS or Windows/WSL)
# Usage: ./install-pmosp.sh

set -e

DEVICE="oneplus-enchilada"
PHONE="OnePlus 6"

echo "========================================="
echo "postmarketOS Installation for $PHONE"
echo "========================================="
echo ""

# Check if running as root (not recommended for pmbootstrap)
if [ "$(id -u)" = "0" ]; then
   echo "ERROR: Do not run pmbootstrap as root. Use your regular user."
   exit 1
fi

# Check we are on Linux
if [ "$(uname -s)" != "Linux" ]; then
   echo "ERROR: This script and pmbootstrap only run on Linux."
   echo "On macOS or Windows, use a Linux VM or live USB instead."
   exit 1
fi

echo "Step 1: Initialize pmbootstrap for $DEVICE"
echo "----------------------------------------"
echo "pmbootstrap init is interactive. Select when prompted:"
echo "  Device: $DEVICE ($PHONE)"
echo "  UI: phosh (recommended) or gnome-mobile / plasma-mobile"
echo ""
read -r -p "Press Enter to start 'pmbootstrap init'..."
pmbootstrap init

echo ""
echo "Step 2: Build the postmarketOS image"
echo "----------------------------------------"
echo "This will take 20-40 minutes..."
echo "Add --fde for full disk encryption (recommended)."
read -r -p "Press Enter to start 'pmbootstrap install'..."
pmbootstrap install

echo ""
echo "Step 3: Export the flashable images"
echo "----------------------------------------"
pmbootstrap export

EXPORT_DIR="/tmp/postmarketOS-export"
ROOTFS_IMG="$EXPORT_DIR/$DEVICE.img"
BOOT_IMG="$EXPORT_DIR/boot.img"

if [ ! -f "$ROOTFS_IMG" ]; then
    echo "ERROR: $ROOTFS_IMG not found."
    echo "Check the output of 'pmbootstrap export' for the real location."
    exit 1
fi
if [ ! -f "$BOOT_IMG" ]; then
    echo "ERROR: $BOOT_IMG not found."
    echo "Check the output of 'pmbootstrap export' for the real location."
    exit 1
fi
echo "Found images:"
ls -lah "$ROOTFS_IMG" "$BOOT_IMG"

echo ""
echo "Step 4: Prepare the device"
echo "----------------------------------------"
echo "Please ensure:"
echo "1. OxygenOS is upgraded to latest version on both slots (recommended)"
echo "2. Bootloader is unlocked: fastboot oem unlock"
echo "3. dtbo partition is erased: fastboot erase dtbo"
echo "   WARNING: erasing dtbo makes Android/TWRP unbootable on this slot!"
echo ""
echo "Put the phone in fastboot mode: adb reboot bootloader"
echo "(or unplug USB and hold Power + Volume Up)"
fastboot devices || {
    echo "ERROR: No fastboot device detected. Connect the phone in fastboot mode."
    exit 1
}

echo ""
echo "Step 5: Flash postmarketOS to phone"
echo "----------------------------------------"
echo "Flashing userdata (this WIPES the userdata partition)..."
fastboot flash userdata "$ROOTFS_IMG"
fastboot flash boot "$BOOT_IMG"

echo ""
echo "Step 6: First boot"
echo "----------------------------------------"
fastboot reboot
echo "DO NOT use the power button to reboot - use: fastboot reboot"
echo ""
echo "Default credentials (may vary by build):"
echo "  Username: user"
echo "  Password: 147147"
echo ""
echo "TTY switching needs: sudo apk add ttyescape"
echo "SSH over USB: ssh user@172.16.42.1 (sshd is enabled by default)"
echo ""
echo "========================================="
echo "Installation complete!"
echo "========================================="