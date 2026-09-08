#!/usr/bin/env bash
# postmarketOS OnePlus 6 Flash Script
# Fastboot flashing operations for the OnePlus 6
#
# FIXES vs previous version:
#   - Destructive operations (userdata flash, dtbo erase) now require typing
#     YES to confirm, instead of running immediately.
#   - Added a combined "Install postmarketOS" option that always erases dtbo
#     before flashing userdata, so that step can no longer be silently
#     skipped. The standalone "flash userdata only" option still exists for
#     advanced use but now warns clearly that dtbo must already be erased.

set -e

DEVICE="oneplus-enchilada"
# pmbootstrap export puts flashable images in /tmp/postmarketOS-export (symlinks)
EXPORT_DIR="/tmp/postmarketOS-export"
IMG_DIR="$EXPORT_DIR"
if [ ! -f "$IMG_DIR/$DEVICE.img" ] && command -v pmbootstrap >/dev/null 2>&1; then
    # Fall back to the image inside the pmbootstrap work chroot
    WORK_DIR=$(pmbootstrap config work 2>/dev/null || true)
    if [ -n "$WORK_DIR" ] && [ -f "$WORK_DIR/chroot_native/home/pmos/rootfs/$DEVICE.img" ]; then
        IMG_DIR="$WORK_DIR/chroot_native/home/pmos/rootfs"
    fi
fi

# Ask for a typed "YES" before a destructive fastboot operation.
# $1 = human-readable description of what is about to happen.
confirm_destructive() {
    echo ""
    echo "WARNING: $1"
    read -r -p "Type YES (all caps) to continue: " confirm
    if [ "$confirm" != "YES" ]; then
        echo "Aborted."
        return 1
    fi
    return 0
}

echo "========================================="
echo "postmarketOS Flash Operations - $DEVICE"
echo "========================================="
echo ""

PS3="Choose an operation: "
options=(
    "Install postmarketOS (recommended: erase dtbo + flash boot + userdata + reboot)"
    "Flash userdata partition only (rootfs) - requires dtbo already erased"
    "Flash boot partition only"
    "Erase dtbo partition (prerequisite before flashing; kills Android on slot)"
    "Verify device connection"
    "Exit"
)

while true; do
    echo ""
    echo "Select flash operation:"
    select opt in "${options[@]}"; do
        case "$REPLY" in
            1)
                if [ -f "$IMG_DIR/$DEVICE.img" ] && [ -f "$IMG_DIR/boot.img" ]; then
                    echo "This will:"
                    echo "  1. Erase dtbo (makes Android/TWRP unbootable on this slot)"
                    echo "  2. Flash userdata (WIPES the userdata partition)"
                    echo "  3. Flash boot"
                    echo "  4. Reboot"
                    if confirm_destructive "This erases dtbo and wipes the userdata partition."; then
                        echo "Erasing dtbo partition..."
                        fastboot erase dtbo
                        echo "Flashing userdata..."
                        fastboot flash userdata "$IMG_DIR/$DEVICE.img"
                        echo "Flashing boot..."
                        fastboot flash boot "$IMG_DIR/boot.img"
                        echo "Rebooting..."
                        fastboot reboot
                        echo "Install complete."
                    fi
                else
                    echo "ERROR: Missing image files in $IMG_DIR"
                    echo "Run 'pmbootstrap export' first (creates $EXPORT_DIR)."
                    ls -la "$IMG_DIR/" 2>/dev/null || true
                fi
                break ;;
            2)
                echo "Enter path to rootfs image (default: $IMG_DIR/$DEVICE.img): "
                read -r img_path
                img_path=${img_path:-$IMG_DIR/$DEVICE.img}
                if [ -f "$img_path" ]; then
                    echo "NOTE: This does NOT erase dtbo. Only use this if dtbo was already"
                    echo "erased (see option 4), otherwise the device may bootloop."
                    if confirm_destructive "This will WIPE the userdata partition."; then
                        fastboot flash userdata "$img_path"
                    fi
                else
                    echo "ERROR: File not found: $img_path"
                    echo "Run 'pmbootstrap export' first (creates $EXPORT_DIR)."
                fi
                break ;;
            3)
                echo "Enter path to boot image (default: $IMG_DIR/boot.img): "
                read -r img_path
                img_path=${img_path:-$IMG_DIR/boot.img}
                if [ -f "$img_path" ]; then
                    echo "Flashing boot..."
                    fastboot flash boot "$img_path"
                else
                    echo "ERROR: File not found: $img_path"
                fi
                break ;;
            4)
                if confirm_destructive "This makes Android and TWRP unbootable on the current slot!"; then
                    fastboot erase dtbo
                    echo "dtbo partition erased."
                fi
                break ;;
            5)
                echo "Checking device connection..."
                fastboot devices
                break ;;
            6)
                echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option $REPLY" ;;
        esac
    done
done
