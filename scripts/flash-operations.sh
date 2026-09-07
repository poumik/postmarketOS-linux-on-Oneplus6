#!/usr/bin/env bash
# postmarketOS OnePlus 6 Flash Script
# Fastboot flashing operations for the OnePlus 6

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

echo "========================================="
echo "postmarketOS Flash Operations - $DEVICE"
echo "========================================="
echo ""

PS3="Choose an operation: "
options=(
    "Flash userdata partition (rootfs)"
    "Flash boot partition"
    "Flash both userdata + boot"
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
                echo "Enter path to rootfs image (default: $IMG_DIR/$DEVICE.img): "
                read -r img_path
                img_path=${img_path:-$IMG_DIR/$DEVICE.img}
                if [ -f "$img_path" ]; then
                    echo "Flashing userdata (WIPES the userdata partition)..."
                    fastboot flash userdata "$img_path"
                else
                    echo "ERROR: File not found: $img_path"
                    echo "Run 'pmbootstrap export' first (creates $EXPORT_DIR)."
                fi
                break ;;
            2) 
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
            3) 
                echo "Flashing userdata and boot..."
                if [ -f "$IMG_DIR/$DEVICE.img" ] && [ -f "$IMG_DIR/boot.img" ]; then
                    fastboot flash userdata "$IMG_DIR/$DEVICE.img"
                    fastboot flash boot "$IMG_DIR/boot.img"
                    echo "Flashing complete."
                else
                    echo "ERROR: Missing image files in $IMG_DIR"
                    echo "Run 'pmbootstrap export' first (creates $EXPORT_DIR)."
                    ls -la "$IMG_DIR/" 2>/dev/null || true
                fi
                break ;;
            4) 
                echo "Erasing dtbo partition..."
                echo "WARNING: This makes Android and TWRP unbootable on the current slot!"
                fastboot erase dtbo
                echo "dtbo partition erased."
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