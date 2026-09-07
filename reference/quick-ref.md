postmarketOS OnePlus 6 (oneplus-enchilada) - Reference Guide

=== WIKI PAGES ===
1. Device Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
2. Installation Guide: https://wiki.postmarketos.org/wiki/Installation
3. pmbootstrap Documentation: https://docs.postmarketos.org/pmbootstrap/main/installation.html
4. Using pmbootstrap: https://wiki.postmarketos.org/index.php?title=pmbootstrap/Using_pmbootstrap
5. OnePlus 6 Unbricking: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)/Unbricking_and_factory_reset

=== KEY COMMANDS ===
# Initialize pmbootstrap
pmbootstrap init

# Build installation
pmbootstrap install
pmbootstrap install --fde  # Full disk encryption

# Flash to device
pmbootstrap flasher flash_rootfs --partition userdata
pmbootstrap flasher flash_kernel

# Post-installation
pmbootstrap os update
pmbootstrap flasher sshd enable  # Enable SSH
pmbootstrap flasher connman restart  # Reset network

# Device-specific
fastboot erase dtbo  # MUST do before first flash
fastboot flash userdata oneplus-enchilada.img
fastboot flash boot boot.img

=== DEFAULT CREDENTIALS ===
Username: user
Password: 147147

=== TTY SWITCH ===
Hold Volume Down + Press Power button 3 times

=== PARTITION LAYOUT ===
- userdata: Main system partition (flashed with postmarketOS image)
- boot: Kernel + initramfs
- dtbo: Device tree bridge (must be erased before flashing)
- persist, modemst1, modemst2: Modem firmware (handled by pmbootstrap)

=== APK MANAGEMENT ===
# Search and install
apk search firefox
apk install firefox

# Update all
apk upgrade

# Flatpak (also available)
apk add flatpak
flatpak remote-add --if-missing flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install firefox

=== TROUBLESHOOTING ===
# Bootloop or black screen
1. Re-enter fastboot: adb reboot bootloader
2. Re-flash: fastboot flash userdata oneplus-enchilada.img
3. Reboot: fastboot reboot

# If stuck on boot
1. Check dtbo was erased: fastboot erase dtbo
2. Re-flash boot: fastboot flash boot boot.img
3. Verify partition: pmbootstrap flasher linaro fastboot get_partition_userdata

=== APPS & FUNCTIONALITY ===
- Phosh UI: Default graphical interface
- Calls/SMS: Basic telephony support
- Wi-Fi: Settings → Network & Internet → Wi-Fi
- Mobile data: Settings → Mobile network
- Bluetooth: Settings → Bluetooth
- Camera: Phosh camera app (limitations expected)
- External display: USB-C video output supported

=== BACKUP & RESTORE ===
# Backup home directory
tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/

# Restore from backup
tar -xzf pmosp-backup.tar.gz

# Important directories
/home/user/        # User home
/home/user/Documents/  # Documents
/home/user/Pictures/   # Photos
/home/user/.config/    # Application configs