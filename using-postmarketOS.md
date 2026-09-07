# Using postmarketOS on OnePlus 6

This guide covers daily usage of postmarketOS on the OnePlus 6 (`oneplus-enchilada`), including updating, app installations, terminal usage, and phone functionality.

## First Boot & Initial Setup

After installation, the first boot will:
- Expand the main partition to occupy all available storage
- Initialize the desktop environment (Phosh by default)
- Set up the default user account

**Default credentials (standard pmbootstrap Phosh build — may vary by build configuration):**
- Username: `user`
- Password: `147147`

## Switching TTY

TTY switching on phones requires the `ttyescape` package:

```bash
sudo apk add ttyescape
```

Once installed, hold **Volume Down** and press the **Power button 3 times** to switch to a text terminal. To return to the GUI, switch back the same way (the F-key method like `Ctrl+Alt+F7` requires an attached physical keyboard).

## Updating postmarketOS

### Method 1: APK (on the phone, recommended)

```bash
sudo apk update && sudo apk upgrade
```

This updates the entire postmarketOS installation, including the kernel, rootfs, and firmware.

> **Note:** There is no `pmbootstrap os update` command. `pmbootstrap update` only refreshes package indexes in your host build chroots — it does not update the phone. From the host you can also rebuild and re-flash: `pmbootstrap install --rsync` (SD-card installs) or `pmbootstrap flasher flash_rootfs` / `flash_kernel`.

### Manual re-flashing

If the system is badly broken, you can re-flash the image from the host:

```bash
pmbootstrap flasher flash_rootfs
pmbootstrap flasher flash_kernel
fastboot reboot
```

## Application Installation

### GUI Applications

Use the graphical app store that comes with your desktop environment:
- **Phosh / GNOME**: `gnome-software`
- **Plasma Mobile**: Discover
- **Sxmo**: CLI-based package management

### Command Line (APK)

postmarketOS is based on Alpine Linux, so packages use `.apk`:

```bash
# Search for an app
apk search firefox

# Install an app (apk add, NOT "apk install")
sudo apk add firefox

# Update all apps
sudo apk upgrade

# Remove an app
sudo apk del firefox
```

### Flatpak

Flatpak is also available:

```bash
# Install Flatpak
sudo apk add flatpak

# Add Flathub remote
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install an app
flatpak install flathub org.mozilla.firefox
```

### Python/pip

```bash
# Install pip
sudo apk add py3-pip

# Install a Python package
pip3 install --user package_name
```

## Terminal Usage

### Basic Commands

- `sudo` - Administrative privileges (password: `147147` in the default build)
- `su` - Switch user
- `reboot` / `shutdown` - System control
- `apk` - Package management (`add`, `del`, `search`, `upgrade`)

### Useful commands (on the phone)

```bash
# Check kernel version
uname -a

# List installed packages
apk list -I

# Update system
sudo apk update && sudo apk upgrade

# Check partition layout
ls -lah /dev/disk/by-partlabel/

# Check modem status
mmcli -m 0
```

> **Note:** `pmbootstrap` itself runs on your **host computer**, not on the phone. There are no `pmbootstrap info`, `pmbootstrap flasher sshd enable`, `pmbootstrap flasher linaro ...` or similar commands — see the pmbootstrap usage docs for the real command list.

### Shell Shortcuts

- `Ctrl+C` - Cancel current command
- `Ctrl+D` - Exit shell (logout)
- `Ctrl+Z` - Suspend current process
- `!` - History expansion (e.g., `!ls` runs last `ls` command)

## Phone Functionality

Status per the OnePlus 6 wiki page — Calls: Partial, SMS: Partial, Mobile data: Partial, VoLTE: experimental (via `81voltd`), GPS: Partial, NFC: Partial.

### Making Calls & SMS

postmarketOS supports basic telephony on the OnePlus 6, but functionality varies by build:
- Calls: Generally work via the Phosh calls app (call audio works with PipeWire since v26.06)
- SMS: Available via ModemManager
- Contacts: Manual entry or sync via GNOME Online Accounts

**Note:** VoLTE is experimental and provided by the `81voltd` service (`sudo apk add 81voltd`, then enable it via `rc-update add 81voltd default` on OpenRC or `systemctl enable 81voltd` on systemd; set the network mode to include 4G). Dual-SIM is poorly supported — use a single SIM if you hit modem issues. Wake-from-suspend on calls/SMS needs ModemManager ≥ 1.24.2-r4 and manual configuration (see wiki). Australia: 3G closure means the device may be rejected for SOS calls.

### Mobile Data

1. Go to Settings → Network → Mobile network
2. Enable "Mobile data"
3. APN settings are usually auto-configured, but may need manual setup if not connecting

### Wi-Fi

1. Settings → Wi-Fi
2. Toggle on and select your network
3. Password entry as usual

**Known Wi-Fi quirks (from wiki):**
- Firmware defaults to US regulatory rules — channels 12/13 of the 2.4 GHz band are ignored and can cause "random" connection failures
- 2.4 GHz may drop out entirely at irregular intervals; 5 GHz association may be denied (code=18)
- Hotspot clients failing to connect → see wiki "WiFi#Troubleshooting"
- Fix option: build a custom `board-2.bin` with the wcn3990-regdomain tool to set your country code (commands on the wiki page)

### Bluetooth

1. Settings → Bluetooth
2. Toggle on and pair with devices

### GPS

Requires a SIM card inserted, GPS enabled in `mmcli`, and Geoclue running. Fix can take ~15 minutes outdoors. See wiki "Troubleshooting:GPS".

### Mobile hotspot

Available via Settings → Network → Hotspot. 2.4 GHz hotspot issues may occur (see Wi-Fi notes).

## Camera

The OnePlus 6 camera is **Partially** supported in mainline:

- The standard camera app on pmOS is **Megapixels**:
  ```bash
  sudo apk add megapixels
  ```
- Front and both rear cameras are packaged in the edge kernel; rear autofocus support is partial (see wiki "Camera" section)
- Photo storage: `~/Pictures/` (Megapixels default)

## Audio

- Speaker: Works (use PipeWire; PulseAudio works but is not recommended for new installs)
- Headphone jack: Works
- Sound settings: GNOME Settings → Sound
- Call audio: works with PipeWire since v26.06 stable (see wiki "Audio in calls" for workarounds)
- Known PipeWire quirk: speaker/mic issues can be fixed by removing `/var/lib/alsa/asound.state` and adding an `alsa-restore.service` override (see wiki "Mic and speaker with Pipewire")
- Replacement battery + wrong battery % readings: BMS device-tree fix documented on the wiki (bq27441→bq27541 dtb edit)

## External Displays & USB OTG — NOT supported

The OnePlus 6 does **not** support DisplayPort alt mode over USB-C, and USB OTG (host mode) is **Broken** upstream. Do not expect video-out or USB accessories to work. (Advanced users can force host mode via DTS/sysfs hacks — see the wiki "OTG doesn't work" section. The phone cannot power accessories itself; a powered hub is required. The wiki links recent USB-C role-switching progress: https://mastodon.social/@tbernard/112679666265497509)

## Battery & Power Management

- Battery status shown in the Phosh top bar
- Idle drain: a large part is caused by always-on camera focus motors; the wiki documents unbinding them (`lc898217xc` driver) when the screen is off
- Consider installing `tlp` (`sudo apk add tlp`) if battery life is suboptimal

## Backup & Sync

### Important directories (on the phone)
- `/home/user/` - User home directory
- `/home/user/Documents/` - Documents
- `/home/user/Pictures/` - Photos
- `/home/user/.config/` - Application configurations

### Backup using tar (run ON THE PHONE or via SSH)

```bash
# On the phone: backup home directory
tar -czf postmarketOS-backup.tar.gz /home/user/

# Restore (on the phone)
tar -xzf postmarketOS-backup.tar.gz -C /
```

> **Note:** These commands run on the phone. To back up from your host computer, pull the file over SSH/USB first (e.g. `scp user@172.16.42.1:~/postmarketOS-backup.tar.gz .`).

## Troubleshooting Common Issues

### Screen Flickering or Black Screen
1. Reboot properly (via `fastboot reboot` from the host if needed)
2. Check the wiki for known firmware issues; upgrade OxygenOS firmware if it was never updated

### No Internet Connection
1. Check Wi-Fi/mobile data settings
2. Try: `nmcli networking on`
3. If stuck, reboot the device (NetworkManager restarts on boot)

### Apps Crashing
1. Update: `sudo apk upgrade`
2. Reinstall: `sudo apk del appname && sudo apk add appname`
3. Check compatibility - some Android-only apps won't work (see Waydroid notes in bestapps.md)

### Bootloop
1. Enter fastboot: `adb reboot bootloader` (or Power + Volume Up)
2. Try switching the A/B slot: `fastboot set_active a` (or `b`)
3. Wipe dtbo on both slots: `fastboot erase dtbo_a && fastboot erase dtbo_b`
4. Re-flash from host: `pmbootstrap flasher flash_rootfs && pmbootstrap flasher flash_kernel`
5. Reboot: `fastboot reboot`
6. If the phone shows "QUALCOMM CrashDump Mode", hold power ~10-15 s to reboot (see wiki)

> Running the phone as a screen-off home server? See `headless-server.md`.

## Tips & Tricks

### Speed Up Boot
- Disable unnecessary startup applications in the GUI
- Reduce console resolution if needed

### Increase Storage
- USB-C OTG/host mode is currently broken on this device — external USB storage will NOT work
- Use network storage (SSH/SCP) instead

### Remote Administration

sshd is enabled by default on classic postmarketOS images. **Newer builds (USB rework, Dec 2025+) disable USB access by default** — enable the "Secure Shell" toggle in the phone's Settings (and/or USB tethering mode from the notification shade) if SSH is refused:

```bash
# Connect from computer over USB networking (default address):
ssh user@172.16.42.1

# mDNS name (modern builds with Avahi):
ssh user@oneplus-enchilada.local

# Or over Wi-Fi:
ssh user@<phone-local-ip>
```

(There is no `pmbootstrap flasher sshd enable` — SSH is on by default; disable at build time with `pmbootstrap install --no-sshd`.)

### Screenshot
- GUI: Phosh screenshot tool / `grim` (wlroots-based UIs):
  ```bash
  sudo apk add grim
  grim screenshot.png
  ```

### Camera flash (torch)
- Two LEDs (yellow + white), max brightness 255. GNOME-mobile extension: https://gitlab.com/NekoCWD/nekotorch

### Tri-state key
- Works out-of-the-box on Phosh with systemd (hardcoded to control feedbackd); needs hkdm configs on other setups (wiki "Tri-state key support")

### Timezone Setup
```bash
sudo apk add tzdata
sudo setup-timezone -z Europe/Helsinki   # or your region/city
```

## References

- [postmarketOS Wiki: OnePlus 6 (oneplus-enchilada)](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada))
- [postmarketOS Documentation](https://wiki.postmarketos.org/wiki/Documentation)
- [Alpine Linux Handbook](https://wiki.alpinelinux.org/wiki/Alpine_Linux)
- [Phosh User Guide](https://wiki.postmarketos.org/wiki/Phosh)
- [pmbootstrap Usage](https://docs.postmarketos.org/pmbootstrap/main/usage.html)