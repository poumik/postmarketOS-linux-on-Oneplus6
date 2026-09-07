#!/usr/bin/env bash
# postmarketOS OnePlus 6 Installation Script
# Prerequisite: pmbootstrap must be installed on your Linux machine
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

echo "Step 1: Initialize pmbootstrap for $DEVICE"
echo "----------------------------------------"
pmbootstrap init <<EOF
$DEVICE
busybox
phosh
EOF

echo ""
echo "Step 2: Build the postmarketOS image"
echo "----------------------------------------"
echo "This will take 20-40 minutes..."
pmbootstrap install --fde

echo ""
echo "Step 3: Prepare the device"
echo "----------------------------------------"
echo "Please ensure:"
echo "1. OxygenOS is upgraded to latest version on both slots"
echo "2. Bootloader is unlocked: fastboot flashing unlock"
echo "3. dtbo partition is erased: fastboot erase dtbo"

echo ""
echo "Step 4: Flash postmarketOS to phone"
echo "----------------------------------------"
echo "Make sure phone is in fastboot mode (adb reboot bootloader)"
fastboot flash userdata oneplus-enchilada.img
fastboot flash boot boot.img

echo ""
echo "Step 5: First boot"
echo "----------------------------------------"
echo "Reboot device: fastboot reboot"
echo "DO NOT use power button - use: fastboot reboot"
echo ""
echo "Default credentials:"
echo "  Username: user"
echo "  Password: 147147"
echo ""
echo "To switch TTY: Hold Volume Down + Press Power 3 times"
echo ""
echo "========================================="
echo "Installation complete!"
echo "========================================="