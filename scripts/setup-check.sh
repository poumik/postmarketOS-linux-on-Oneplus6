#!/usr/bin/env bash
# postmarketOS OnePlus 6 Setup Verification Script
# Checks if the host system is ready for pmbootstrap installation
# NOTE: pmbootstrap only runs on Linux (not macOS, not WSL).

set -e

echo "========================================="
echo "postmarketOS OnePlus 6 Setup Check"
echo "========================================="
echo ""

FAILED=0

# Check we are on Linux
echo "Checking operating system..."
if [ "$(uname -s)" != "Linux" ]; then
    echo "✗ Not running on Linux ($(uname -s))."
    echo "  pmbootstrap does not support macOS, and WSL does not work."
    echo "  Use a Linux VM or live USB instead."
    FAILED=1
else
    echo "✓ Running on Linux"
fi

echo ""

# Check if pmbootstrap is installed
echo "Checking pmbootstrap installation..."
if command -v pmbootstrap &>/dev/null; then
    echo "✓ pmbootstrap is installed"
    pmbootstrap --version
else
    echo "✗ pmbootstrap NOT found"
    echo "  Install (Linux only):"
    echo "    Alpine/pmOS:   sudo apk add pmbootstrap"
    echo "    Arch:          sudo pacman -S pmbootstrap"
    echo "    Debian/Ubuntu: sudo apt install pmbootstrap"
    echo "    Fedora:        sudo dnf install pmbootstrap"
    echo "    Any distro:    git clone --depth=1 https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git"
    FAILED=1
fi

echo ""

# Check for fastboot/adb tools
echo "Checking fastboot/adb tools..."
if command -v fastboot &>/dev/null; then
    echo "✓ fastboot is available"
else
    echo "✗ fastboot NOT found"
    echo "  Install: sudo apt install fastboot  (Debian/Ubuntu)"
    echo "           sudo apk add android-tools (Alpine)"
    echo "           sudo pacman -S android-tools (Arch)"
    FAILED=1
fi

if command -v adb &>/dev/null; then
    echo "✓ adb is available"
else
    echo "✗ adb NOT found"
    echo "  Install: sudo apt install adb  (Debian/Ubuntu)"
    echo "           sudo apk add android-tools (Alpine)"
    echo "           sudo pacman -S android-tools (Arch)"
    FAILED=1
fi

echo ""

# Check for sufficient disk space (pmbootstrap needs ~10 GB free)
echo "Checking disk space (work dir lives in \$HOME)..."
HOME_MB=$(df -Pk "$HOME" | awk 'NR==2 {print int($4/1024)}')
if [ "$HOME_MB" -ge 10240 ]; then
    echo "✓ $HOME has ${HOME_MB} MB free (>= 10 GB recommended)"
else
    echo "⚠ Only ${HOME_MB} MB free in $HOME (pmbootstrap builds want ~10 GB)"
fi

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
if [ "$FAILED" -ne 0 ]; then
    echo "Some checks failed - fix the items marked ✗ above before continuing."
    echo ""
fi
echo "Next steps:"
echo "1. Enable developer options on OnePlus 6 (tap Build number ~7 times)"
echo "2. Enable USB debugging + OEM unlocking"
echo "3. Unlock bootloader: fastboot oem unlock (erases all data!)"
echo "4. Erase dtbo: fastboot erase dtbo (makes Android/TWRP unbootable on slot)"
echo "5. Run: pmbootstrap init (interactive; select oneplus-enchilada, phosh)"
echo "6. Run: pmbootstrap install (add --fde for full disk encryption)"
echo "7. Run: pmbootstrap export, then flash:"
echo "   pmbootstrap flasher flash_rootfs && pmbootstrap flasher flash_kernel"
echo "   fastboot reboot"
echo ""
echo "See: reference/quick-ref.md for quick reference"