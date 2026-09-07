# postmarketOS Installation Guide for OnePlus 6

This guide covers the complete installation of postmarketOS on the OnePlus 6 (codename: `oneplus-enchilada`).

## Prerequisites

- A OnePlus 6 device
- A computer running **Linux** (pmbootstrap does not support macOS or Windows/WSL — see Step 5)
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
- postmarketOS dual-boot is officially unsupported
- See the "Dual Booting" section at the end for partitioning guidance

1. Go to Settings → About Phone
2. Tap the Build number ~10 times to enable Developer Options
3. Go back to Settings → System → Developer options
4. Enable "OEM unlocking"
5. Use OTA updates or the third-party `oxygen-updater` app to update to the latest OxygenOS version
6. Ensure both system slots are on the same latest version

> **Note (from wiki):** If GPS/VoLTE matter to you, flash OxygenOS 9.0.8 for enchilada instead of the latest version. Very old OxygenOS versions (e.g. after MSM Download tool) may need two update passes because of A/B partitioning.

## Step 2: Enable Developer Options and USB Debugging

1. **Enable Developer Options:** Go to Settings → About Phone → Tap "Build number" ~10 times until you see "You are now a developer"
2. **Enable USB Debugging:** Go to Settings → System → Developer options → Toggle "USB debugging" on

## Step 3: Unlock the Bootloader

1. With USB debugging enabled, connect the OnePlus 6 to your computer
2. Open a terminal and enter fastboot mode:
   ```bash
   adb reboot bootloader
   ```
   (Or manually: unplug USB, hold **Power + Volume Up** until the START screen appears)
3. Unlock the bootloader:
   ```bash
   fastboot oem unlock
   ```
   - This is the command the official OnePlus 6 wiki page documents. If `fastboot oem unlock` doesn't work on your host (e.g. `< waiting for any device >`), try running it with `sudo` and reboot the device into fastboot again by selecting "Restart Bootloader" on the device
   - On some carriers (particularly T-Mobile US), you may need to obtain an unlock code from Google first
   - Arch Linux users: if you get `std::out_of_range` errors, uninstall `android-tools` and install `android-sdk-platform-tools` from the AUR instead
   - Confirm the unlock on the phone screen. **THIS WILL ERASE THE DEVICE'S INTERNAL STORAGE**

## Step 4: Erase dtbo Partition

The dtbo partition contains information that will cause the bootloader to break the postmarketOS image. It must be erased before flashing:

```bash
fastboot erase dtbo
```

⚠ **Warning:** Erasing dtbo makes Android **and all Android-based software (TWRP, Ubuntu Touch)** unbootable on the current slot. You can return to Android later by re-flashing an Android ROM via fastboot (extracting partition images from the OTA zip).

Then reboot with:

```bash
fastboot reboot
```

All done — continue with Step 5 below.

## Step 5: Install pmbootstrap

pmbootstrap only runs on **Linux** (x86, x86_64, aarch64, armv7). It is **not supported on macOS, and WSL explicitly does not work** — use a Linux VM or live USB instead if you don't have Linux.

Install the postmarketOS build tool on your host computer:

**Alpine Linux / postmarketOS:**
```bash
sudo apk add pmbootstrap
```

**Arch Linux:**
```bash
sudo pacman -S pmbootstrap
```

**Debian / Ubuntu / Fedora:**
```bash
# Debian/Ubuntu
sudo apt install pmbootstrap
# Fedora
sudo dnf install pmbootstrap
```

**Any distro (from git, always up to date):**
```bash
git clone --depth=1 https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git
mkdir -p ~/.local/bin
ln -s "$PWD/pmbootstrap/pmbootstrap.py" ~/.local/bin/pmbootstrap
# ensure ~/.local/bin is in your PATH
pmbootstrap --version
```

During the interactive `pmbootstrap init` (next step), select:
- Device: `oneplus-enchilada` (OnePlus 6)
- UI: `phosh` (recommended), `gnome-mobile`, or `plasma-mobile`

## Step 6: Build the postmarketOS Image

Initialize and build:

```bash
pmbootstrap init
pmbootstrap install
```

or with full disk encryption:

```bash
pmbootstrap install --fde
```

After the build, export the flashable files (they are placed in `/tmp/postmarketOS-export/` as symlinks):

```bash
pmbootstrap export
```

This produces:
- `oneplus-enchilada.img` - Rootfs image (the main system, flashed to `userdata`)
- `boot.img` - Fastboot compatible boot image (kernel + initramfs)
- `initramfs`, `initramfs-extra`, `vmlinuz` - Boot components
- (and optionally `dtbo.img`, `lk2nd.img` depending on device)

> **Note:** `pmbootstrap init` is fully interactive and must be answered manually. Do not try to pipe answers into it.

## Step 6.5: Prepare Partition Layout (Optional but Recommended)

If you want to dual-boot with Android or customize partitions:

1. Check the current partition layout on the device (from the phone, via SSH or a terminal on the phone):
   ```bash
   ls -lah /dev/disk/by-partlabel/
   ```
2. See the wiki page "OnePlus 6 (oneplus-enchilada)/Multi-booting and custom partitioning" before resizing anything

## Step 7: Flash postmarketOS

The easiest way — let pmbootstrap flash for you (device must be in fastboot mode):

```bash
pmbootstrap flasher flash_rootfs    # flashes oneplus-enchilada.img to userdata
pmbootstrap flasher flash_kernel    # flashes boot.img to boot
```

Or flash manually with fastboot (device in fastboot mode via `adb reboot bootloader`):

```bash
fastboot flash userdata /tmp/postmarketOS-export/oneplus-enchilada.img
fastboot flash boot /tmp/postmarketOS-export/boot.img
```

> **Tip:** If fastboot gets stuck or shows odd errors ("device does not support slots"), unplug the USB cable, prepare the command in your terminal, choose "Reboot bootloader" on the device, and plug the cable back in while it reboots.

3. **Critical:** Always flash using `fastboot` (or `pmbootstrap flasher`), NOT via recovery

## Step 8: Reboot

1. Reboot the device:
   ```bash
   fastboot reboot
   ```

2. **DO NOT** reboot using the power button on the device - this can corrupt the rootfs. Always use `fastboot reboot` after flashing.

## Step 9: First Boot

The first boot will take several minutes as it:
- Expands the main partition to occupy all available storage
- Initializes the desktop environment
- Sets up initial user accounts

Default credentials for standard pmbootstrap builds:
- Username: `user`
- Password: `147147`

> **Note:** Credentials may vary by build configuration — you set the user password during `pmbootstrap install` / `init`.

## Step 10: Post-Installation Setup

1. **Update the system** (on the phone, via terminal or SSH):
   ```bash
   sudo apk update && sudo apk upgrade
   ```
   (`pmbootstrap update` only refreshes package indexes in your host build chroots — it does not update the phone.)

2. **SSH:** sshd is **enabled by default** on postmarketOS images. Connect over USB:
   ```bash
   ssh user@172.16.42.1
   ```
   (Disable at build time with `pmbootstrap install --no-sshd` if desired.)

3. **Switch to TTY:** Requires the `ttyescape` package (`sudo apk add ttyescape`). Once installed, hold **Volume Down** and press the **Power button 3 times** to switch to a text terminal.

4. **Change UI:** If you want a different interface, change it and rebuild:
   ```bash
   pmbootstrap config ui gnome-mobile   # or plasma-mobile, sxmo, ...
   pmbootstrap install                  # rebuild with the new UI
   pmbootstrap flasher flash_rootfs
   ```

## Troubleshooting

### Bootloop or Black Screen
1. Re-enter fastboot mode: `adb reboot bootloader` (or unplug USB, hold Power + Volume Up)
2. Check that firmware is up to date — if you only get a blank screen after reboot, firmware may never have been upgraded. See "Upgrading firmware without Android installed" on the wiki page (extract payload.bin from the OxygenOS OTA zip with payload-dumper-go, `fastboot flashing unlock_critical`, then flash abl/aop/tz/xbl/... partition images and `fastboot flash --slot=all modem modem.img`)
3. Re-flash: `pmbootstrap flasher flash_rootfs && pmbootstrap flasher flash_kernel`
4. Reboot: `fastboot reboot`

### Bootloader Issues
- Restart into fastboot mode (the bootloader can be buggy — restarting it helps)
- Ensure dtbo partition was erased: `fastboot erase dtbo`
- Try flashing again; if fastboot hangs or shows "device does not support slots", use the unplug/replug workaround in Step 7
- Arch Linux fastboot `std::out_of_range` errors: use `android-sdk-platform-tools` from the AUR instead of `android-tools`

### QUALCOMM CrashDump Mode
If the device crash-dumps, hold the power button ~10-15 seconds to reboot. Firmware upgrades and re-flashing often fix frequent crashes (see wiki for details).

### If Everything Goes Wrong (Brick)
- The OnePlus 6 has easy EDL (Emergency Download) mode access, so it is rarely permanently bricked
- Follow the wiki page: "OnePlus 6 (oneplus-enchilada)/Unbricking and factory reset"
- (There is no `pmbootstrap unbrick` command — unbricking is done with Qualcomm EDL tools as described on the wiki.)

## Dual Booting

Dual-booting is officially unsupported by postmarketOS. It is possible with caution — refer to the wiki page "OnePlus 6 (oneplus-enchilada)/Multi-booting and custom partitioning" for custom partitioning instructions.

## References

- [postmarketOS Wiki: OnePlus 6 (oneplus-enchilada)](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada))
- [postmarketOS Installation Guide](https://wiki.postmarketos.org/wiki/Installation)
- [pmbootstrap Documentation](https://docs.postmarketos.org/pmbootstrap/main/installation.html)
- [Unbricking and factory reset](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)/Unbricking_and_factory_reset)
- [Multi-booting and custom partitioning](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)/Multi-booting_and_custom_partitioning)