# postmarketOS Installation Guide for OnePlus 6

This guide covers the complete installation of postmarketOS on the OnePlus 6 (codename: `oneplus-enchilada`).

## Prerequisites

- A OnePlus 6 device
- A computer with Linux, macOS, or Windows (via WSL)
- USB cable
- Approximately 30-60 minutes

## Step 1: Upgrade OxygenOS (Optional if replacing Android)

**If you want to erase Android and install postmarketOS as the only OS:**

You can skip the OxygenOS upgrade if you're comfortable starting fresh. However, if you currently have Android installed and want to keep it while installing postmarketOS, upgrade to the latest OxygenOS first (see dual-boot notes below).

**If installing postmarketOS as the ONLY OS (erasing Android):**

1. Back up any important data from the internal storage
2. You can proceed directly to unlocking the bootloader
3. The postmarketOS installation will use the userdata partition, effectively replacing Android

**If dual-booting with Android:**
- Upgrade both system slots to the latest OxygenOS
- postmarketOS supports dual-boot but this is officially unsupported
- See the "Dual Booting" section at the end for partitioning guidance

1. Go to Settings → About Phone
2. Tap the Build number ~7 times to enable Developer Options
3. Go back to Settings → System → Developer options
4. Enable "OEM unlocking"
5. Use OTA updates or the community `oxygen-updater` app to update to the latest OxygenOS version
6. Ensure both system slots are on the same latest version

## Step 2: Enable Developer Options and USB Debugging

1. **Enable Developer Options:** Go to Settings → About Phone → Tap "Build number" ~7 times until you see "You are now a developer"
2. **Enable USB Debugging:** Go to Settings → System → Developer options → Toggle "USB debugging" on

## Step 3: Unlock the Bootloader

1. With USB debugging enabled, connect the OnePlus 6 to your computer
2. Open a terminal and enter fastboot mode:
   ```bash
   adb reboot bootloader
   ```
3. Unlock the bootloader:
   ```bash
   fastboot flashing unlock
   ```
   - On some carriers (particularly T-Mobile US), you may need to obtain an unlock code from Google first
   - If `fastboot flashing unlock` doesn't work, search for your specific carrier variant guide

## Step 4: Erase dtbo Partition

The dtbo partition contains information that can cause the bootloader to break postmarketOS. Must be erased before flashing:

```bash
fastboot erase dtbo
```

## Step 5: Install pmbootstrap

Install the postmarketOS build tool on your host computer:

**Linux:**
```bash
sudo pmbootstrap init
```

**macOS:**
```bash
brew install pmbootstrap
pmbootstrap init
```

**Windows (WSL):**
```bash
sudo apt install pmbootstrap
pmbootstrap init
```

During init, select:
- Device: `oneplus-enchilada` (OnePlus 6)
- Shell: `busybox`
- Window system: `phosh` (recommended) or `gnome` or `plasma-mobile`

## Step 6: Build the postmarketOS Image

Build the device image with full disk encryption support (optional):

```bash
pmbootstrap install
```
or for full disk encryption:
```bash
pmbootstrap install --fde
```

This will produce several files in `/tmp/postmarketOS-export/`:
- `boot.img` - Fastboot compatible boot image
- `initramfs` - Initial RAM filesystem
- `vmlinuz` - Linux kernel
- `userdata.img` - User data partition image

## Step 6.5: Prepare Partition Layout (Optional but Recommended)

If you want to dual-boot with Android or customize partitions:

1. Check current partition layout:
   ```bash
   pmbootstrap flasher linaro fastboot get_partition_userdata
   ```
2. Resize partitions if needed using `fastboot` commands

## Step 7: Flash postmarketOS

1. Boot into fastboot mode (if not already):
   ```bash
   adb reboot bootloader
   ```

2. Flash the userdata partition (this is the main system partition):
   ```bash
   fastboot flash userdata oneplus-enchilada.img
   ```
   - The `oneplus-enchilada.img` is typically found at `~/.local/var/pmbootstrap/installed/images/oneplus-enchilada/userdata.img` after `pmbootstrap install`

3. **Critical:** Always flash using `fastboot`, NOT via recovery

## Step 8: Flash Boot and Kernel

```bash
fastboot flash boot boot.img
```
or combined:
```bash
fastboot flash boot combined.img
```

## Step 9: First Boot

1. Reboot the device:
   ```bash
   fastboot reboot
   ```

2. **DO NOT** reboot using the power button on the device - this can corrupt the rootfs

3. The first boot will take several minutes as it:
   - Expands the main partition to occupy all available storage
   - Initializes the desktop environment
   - Sets up initial user accounts

4. Default credentials:
   - Username: `user`
   - Password: `147147`

## Step 10: Post-Installation Setup

1. **Switch UI:** If you installed Phosh but want another interface:
   ```bash
   pmbootstrap init  # Re-init to change UI
   ```

2. **Enable SSH:**
   ```bash
   pmbootstrap flasher sshd enable
   ```

3. **Switch to TTY:** At any time, hold Volume Down and press Power button 3 times

4. **Update system:**
   ```bash
   pmbootstrap os update
   ```

## Troubleshooting

### Bootloop or Black Screen
1. Re-enter fastboot mode: `adb reboot bootloader`
2. Re-flash: `fastboot flash userdata oneplus-enchilada.img`
3. Reboot: `fastboot reboot`

### Bootloader Issues
- Restart into fastboot mode
- Ensure dtbo partition was erased: `fastboot erase dtbo`
- Try flashing again

### If Everything Goes Wrong (Brick)
- OnePlus 6 has easy EDL (Emergency Download) mode access
- Use Qualcomm's EDL tool or `pmbootstrap unbrick` procedures
- The device is rarely permanently bricked due to the unlocked bootloader

## Dual Booting

Officially unsupported but possible with caution. Refer to the postmarketOS wiki page for `oneplus-enchilada`/Multi-booting for custom partitioning instructions.

## References

- [postmarketOS Wiki: OnePlus 6 (oneplus-enchilada)](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada))
- [postmarketOS Installation Guide](https://wiki.postmarketos.org/wiki/Installation)
- [pmbootstrap Documentation](https://pmbootstrap.org/docs/)