#!/usr/bin/env bash
# postmarketOS OnePlus 6 Daily Operations Script
# Interactive menu for common daily tasks.
# This script runs on the HOST computer and talks to the phone over SSH/USB.
# The phone must be connected via USB (sshd is enabled by default in pmOS).
#
# FIXES vs previous version:
#   - Backup/restore no longer leaves the tar archive behind in /tmp on the
#     phone; it is removed after the transfer completes.
#   - User-supplied search/package-name input is now safely single-quote
#     escaped before being embedded in the remote SSH command string,
#     instead of being wrapped in raw single quotes (which broke if the
#     input itself contained a quote character).

set -e

DEVICE="oneplus-enchilada"
PHONE_USER="user"
PHONE_HOST="172.16.42.1"   # default pmOS USB networking address

# Allow overriding target, e.g. ./daily-use.sh user@192.168.1.50
if [ -n "$1" ]; then
    PHONE_TARGET="$1"
else
    PHONE_TARGET="$PHONE_USER@$PHONE_HOST"
fi

echo "========================================="
echo "postmarketOS Daily Use - $DEVICE"
echo "Target: $PHONE_TARGET"
echo "========================================="
echo ""

# Check connectivity first
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$PHONE_TARGET" true 2>/dev/null; then
    echo "NOTE: No working SSH connection to $PHONE_TARGET (BatchMode probe failed)."
    echo "You will be prompted for the phone password (default: 147147)."
    echo ""
fi

phone() {
    ssh "$PHONE_TARGET" "$@"
}

# POSIX-safe single-quote escaping for embedding user input into the
# remote shell command (works whether the phone's shell is bash or ash).
shquote() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

PS3="Choose an operation: "
options=(
    "Update phone system (apk update + upgrade)"
    "Search packages on phone"
    "Install a package on phone"
    "Remove a package on phone"
    "List installed packages"
    "Backup phone home directory (tar over SSH)"
    "Restore backup to phone"
    "Check battery / power status"
    "Check modem status (mmcli)"
    "Exit"
)

while true; do
    echo ""
    echo "Select daily operation:"
    select opt in "${options[@]}"; do
        case "$REPLY" in
            1)
                phone "sudo apk update && sudo apk upgrade"
                break ;;
            2)
                read -r -p "Search term: " term
                phone "apk search $(shquote "$term")"
                break ;;
            3)
                read -r -p "Package name: " pkg
                phone "sudo apk add $(shquote "$pkg")"
                break ;;
            4)
                read -r -p "Package name: " pkg
                phone "sudo apk del $(shquote "$pkg")"
                break ;;
            5)
                phone "apk list -I | head -50"
                break ;;
            6)
                read -r -p "Backup file name [pmosp-backup-$(date +%Y%m%d).tar.gz]: " bfile
                bfile=${bfile:-pmosp-backup-$(date +%Y%m%d).tar.gz}
                qbfile=$(shquote "$bfile")
                # Run tar ON the phone, pull the archive to the host, then
                # remove the temporary copy left on the phone.
                phone "tar -czf /tmp/$bfile /home/$PHONE_USER/ 2>/dev/null" || true
                scp "$PHONE_TARGET:/tmp/$bfile" .
                phone "rm -f /tmp/$qbfile"
                echo "Backup saved to ./$(basename "$bfile")"
                break ;;
            7)
                read -r -p "Backup file to restore: " bfile
                if [ -f "$bfile" ]; then
                    scp "$bfile" "$PHONE_TARGET:/tmp/restore.tar.gz"
                    phone "tar -xzf /tmp/restore.tar.gz -C /"
                    phone "rm -f /tmp/restore.tar.gz"
                    echo "Restore complete."
                else
                    echo "ERROR: File not found: $bfile"
                fi
                break ;;
            8)
                phone "cat /sys/class/power_supply/battery/capacity 2>/dev/null; cat /sys/class/power_supply/battery/status 2>/dev/null" || echo "Battery info unavailable"
                break ;;
            9)
                phone "mmcli -m 0" || echo "mmcli unavailable or no modem"
                break ;;
            10)
                echo "Goodbye!"
                exit 0 ;;
            *)
                echo "Invalid option $REPLY"
                break ;;
        esac
    done
done
