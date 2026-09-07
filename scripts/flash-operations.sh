#!/usr/bin/env bash
# postmarketOS OnePlus 6 Flash Script
# Fastboot flashing operations for the OnePlus 6

set -e

DEVICE="oneplus-enchilada"
IMG_DIR="$HOME/.local/var/pmbootstrap/installed/images/$DEVICE"

echo "========================================="
echo "postmarketOS Flash Operations - $DEVICE"
echo "========================================="
echo ""

PS3="Choose an operation: "
options=(
    "Flash userdata partition"
    "Flash boot partition"
    "Flash both userdata + boot"
    "Erase dtbo partition (prerequisite before flashing)"
    "Verify device connection"
    "Exit"
)

while true; do
    echo ""
    echo "Select flash operation:"
    select opt in "${options[@]}"; do
        case "$REPLY" in
            1) 
                echo "Enter path to userdata image (default: $IMG_DIR/userdata.img): "
                read -r img_path
                img_path=${img_path:-$IMG_DIR/userdata.img}
                if [ -f "$img_path" ]; then
                    echo "Flashing userdata..."
                    fastboot flash userdata "$img_path"
                else
                    echo "ERROR: File not found: $img_path"
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
                if [ -f "$IMG_DIR/userdata.img" ] && [ -f "$IMG_DIR/boot.img" ]; then
                    fastboot flash userdata "$IMG_DIR/userdata.img"
                    fastboot flash boot "$IMG_DIR/boot.img"
                    echo "Flashing complete."
                else
                    echo "ERROR: Missing image files in $IMG_DIR"
                    ls -la "$IMG_DIR/"
                fi
                break ;;
            4) 
                echo "Erasing dtbo partition..."
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