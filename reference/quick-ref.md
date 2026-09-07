postmarketOS OnePlus 6 (oneplus-enchilada) - Reference Guide

=== WIKI PAGES ===
1. Device Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
2. Installation Guide: https://wiki.postmarketos.org/wiki/Installation
3. pmbootstrap Documentation: https://docs.postmarketos.org/pmbootstrap/main/installation.html
4. pmbootstrap Usage: https://docs.postmarketos.org/pmbootstrap/main/usage.html
5. OnePlus 6 Unbricking: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)/Unbricking_and_factory_reset
6. Multi-booting: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)/Multi-booting_and_custom_partitioning

=== KEY COMMANDS (host computer) ===
# Initialize pmbootstrap (interactive - answer prompts manually)
pmbootstrap init

# Build installation
pmbootstrap install
pmbootstrap install --fde  # Full disk encryption

# Export flashable images -> /tmp/postmarketOS-export/
pmbootstrap export
#   oneplus-enchilada.img (rootfs), boot.img, initramfs, vmlinuz, dtbo.img

# Flash to device (phone in fastboot mode)
pmbootstrap flasher flash_rootfs
pmbootstrap flasher flash_kernel
# Manual equivalent:
fastboot flash userdata /tmp/postmarketOS-export/oneplus-enchilada.img
fastboot flash boot /tmp/postmarketOS-export/boot.img
fastboot reboot

# Refresh host build chroot package indexes (NOT a phone update)
pmbootstrap update

=== DEVICE PREP (fastboot mode) ===
fastboot oem unlock        # Unlock bootloader (erases ALL data)
fastboot erase dtbo        # MUST do before first flash
                           # WARNING: makes Android/TWRP unbootable on slot
fastboot reboot            # ALWAYS reboot this way (never power button)

=== DEFAULT CREDENTIALS ===
Username: user
Password: 147147
(standard pmbootstrap build; may vary by build configuration)

=== TTY SWITCH ===
Requires ttyescape: sudo apk add ttyescape
Then: hold Volume Down + press Power button 3 times

=== PARTITION LAYOUT ===
- userdata: Main system partition (flashed with oneplus-enchilada.img)
- boot: Kernel + initramfs (flashed with boot.img)
- dtbo: Device tree overlay (must be ERASED before flashing pmOS)
- Check on phone: ls -lah /dev/disk/by-partlabel/

=== APK MANAGEMENT (on the phone) ===
# Search and install (apk add, NOT "apk install")
apk search firefox
sudo apk add firefox

# Update all
sudo apk update && sudo apk upgrade

# Remove
sudo apk del firefox

# Flatpak (also available)
sudo apk add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.mozilla.firefox

=== SSH ===
# sshd is enabled by DEFAULT on classic pmOS images
# NEW builds (USB rework Dec 2025+): USB access is DISABLED by default -
#   enable "Secure Shell" toggle in phone Settings + USB tethering mode
# Over USB networking (default address):
ssh user@172.16.42.1
# mDNS name (modern builds with Avahi):
ssh user@oneplus-enchilada.local
# Over Wi-Fi:
ssh user@<phone-local-ip>

=== TROUBLESHOOTING ===
# Bootloop or black screen
1. Enter fastboot: adb reboot bootloader (or Power + Volume Up)
2. Switch A/B slot: fastboot set_active a   (or: fastboot set_active b)
3. Wipe dtbo on BOTH slots: fastboot erase dtbo_a && fastboot erase dtbo_b
4. Re-flash from host: pmbootstrap flasher flash_rootfs && pmbootstrap flasher flash_kernel
5. Reboot: fastboot reboot
6. QUALCOMM CrashDump screen? Hold power ~10-15 s (see wiki)
7. Still broken: wiki "Unbricking and factory reset" page (EDL mode)

# Fastboot hangs / "device does not support slots"
Unplug USB, pick "Reboot bootloader" on device, run command, plug cable in.

# No network on phone
nmcli networking on
(Wi-Fi note: firmware defaults to US regs - channels 12/13 blocked)

# SIM not appearing (increase wait time, wiki)
# OpenRC: sed sim_wait_time=30 in /etc/conf.d/msm-modem-uim-selection
# systemd: drop-in override with Environment=SIM_WAIT_TIME=30

# Modem log collection (wiki "Modem bugs")
# ModemManager --debug 2>&1 | tee mm.log
# sudo qmicli -d qrtr://0 --uim-get-card-status

=== HARDWARE STATUS (per wiki) ===
Works: Flashing, USB networking, storage, battery, screen, touch, GPU, audio,
       Bluetooth, camera flash (torch), FDE, haptics, accelerometer,
       magnetometer, ambient light, proximity
Partial: Camera, WiFi, GPS, NFC, calls, SMS, mobile data (VoLTE experimental)
Broken: Fingerprint, USB OTG/host mode, USB-C DisplayPort alt mode (no video out),
        Hall effect sensor

=== FIRMWARE / FIRMWARE UPGRADE ===
# GPS+VoLTE need OxygenOS 9.0.8 (enchilada) / 9.0.16 (fajita), NOT the latest!
# Blank screen after install = firmware never upgraded. Fix (wiki):
#   payload-dumper-go payload.bin  (from OxygenOS OTA zip)
#   fastboot flashing unlock_critical
#   flash abl aop tz xbl ... images, then:
#   fastboot flash --slot=all modem modem.img

=== PHONE TIPS ===
# Camera (partial support) - Megapixels is the standard app
sudo apk add megapixels

# Screenshots (wlroots/Phosh)
sudo apk add grim && grim screenshot.png

# Battery idle drain fix (unbind camera focus motors, see wiki)
echo "16-0072" | sudo tee /sys/bus/i2c/drivers/lc898217xc/unbind
echo "17-0074" | sudo tee /sys/bus/i2c/drivers/lc898217xc/unbind

# Timezone
sudo apk add tzdata && sudo setup-timezone -z Region/City

=== HEADLESS SERVER MODE ===
# See headless-server.md for the full guide
# Check init system first: ps -p 1 -o comm=
# Disable desktop (systemd):   sudo systemctl disable greetd && sudo reboot
# Re-enable desktop (systemd): sudo systemctl enable greetd && sudo reboot
# Disable (OpenRC):  sudo rc-update del display-manager default
# Re-enable (OpenRC): sudo rc-update add display-manager default
# Server packages (verified in Alpine aarch64):
#   fastfetch tmux docker docker-cli-compose samba samba-common-tools nginx ufw distrobox
# neofetch and macchina are NOT in Alpine repos - use fastfetch

=== BACKUP & RESTORE (run ON THE PHONE or via SSH) ===
# Backup home directory
tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/

# Restore from backup
tar -xzf pmosp-backup.tar.gz -C /

# Pull backup to host
scp user@172.16.42.1:~/pmosp-backup-*.tar.gz .

# Important directories (on phone)
/home/user/             # User home
/home/user/Documents/   # Documents
/home/user/Pictures/    # Photos
/home/user/.config/     # Application configs