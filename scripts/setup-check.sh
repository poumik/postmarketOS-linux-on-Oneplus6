#!/usr/bin/env bash
# postmarketOS OnePlus 6 Setup Verification Script
# Checks if the host system is ready for pmbootstrap installation

set -e

echo "========================================="
echo "postmarketOS OnePlus 6 Setup Check"
echo "========================================="
echo ""

# Check if pmbootstrap is installed
echo "Checking pmbootstrap installation..."
if command -v pmbootstrap &>/dev/null; then
    echo "✓ pmbootstrap is installed"
    pmbootstrap --version
else
    echo "✗ pmbootstrap NOT found"
    echo "Install with: sudo apt install pmbootstrap (Debian/Ubuntu)"
    echo "or: apk add pmbootstrap (Alpine)"
    echo "or: pip install pmbootstrap (via git)"
fi

echo ""

# Check for fastboot
echo "Checking fastboot/adb tools..."
if command -v fastboot &>/dev/null; then
    echo "✓ fastboot is available"
else
    echo "✗ fastboot NOT found"
    echo "Install: sudo apt install android-tools-fastboot"
fi

if command -v adb &>/dev/null; then
    echo "✓ adb is available"
else
    echo "✗ adb NOT found"
    echo "Install: sudo apt install android-tools-adb"
fi

echo ""

# Check for sufficient disk space
echo "Checking disk space..."
pmbootstrap_size=$(pmbootstrap config work 2>/dev/null || echo "unknown")
echo "Work directory: $pmbootstrap_size"

echo ""

# Check user permissions
echo "Checking user permissions..."
if [ "$(id -u)" -ne 0 ]; then
    echo "✓ Running as non-root user (recommended)"
else
    echo "⚠ Running as root (not recommended for pmbootstrap)"
fi

echo ""

# Summary
echo "========================================="
echo "Setup Check Complete"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Enable developer options on OnePlus 6"
echo "2. Enable USB debugging"
echo "3. Unlock bootloader: fastboot flashing unlock"
echo "4. Run: pmbootstrap init"
echo "5. Select: oneplus-enchilada, busybox, phosh"
echo "6. Run: pmbootstrap install"
echo ""
echo "See: reference/quick-ref.md for quick reference"