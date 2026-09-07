# Using postmarketOS on OnePlus 6

This guide covers daily usage of postmarketOS on the OnePlus 6 (`oneplus-enchilada`), including updating, app installations, terminal usage, and phone functionality.

## First Boot & Initial Setup

After installation, the first boot will:
- Expand the main partition to occupy all available storage
- Initialize the desktop environment (Phosh by default)
- Set up the default user account

**Default credentials:**
- Username: `user`
- Password: `147147`

## Switching TTY

At any time, switch to a text terminal by holding **Volume Down** and pressing the **Power button 3 times**. To return to the GUI, press `Ctrl+Alt+F7` (or whichever F-key has the display).

## Updating postmarketOS

### Method 1: pmbootstrap (recommended)

```bash
pmbootstrap os update
```

This updates the entire postmarketOS installation, including the kernel, rootfs, and firmware.

### Method 2: Alpine Linux packages

```bash
sudo apk update && sudo apk upgrade
```

### Manual flashing

If `pmbootstrap os update` fails, you can re-flash the image:
```bash
fastboot flash userdata oneplus-enchilada.img
fastboot reboot
```

## Application Installation

### GUI Applications

Use the graphical app store that comes with your chosen desktop environment:
- **Phosh**: Uses `gpk-application` (GNOME Software backend)
- **Plasma Mobile**: Uses Discover
- **Sxmo**: CLI-based package management

### Command Line (APK)

postmarketOS is based on Alpine Linux, so packages use `.apk`:

```bash
# Search for an app
apk search firefox

# Install an app
apk install firefox

# Update all apps
apk upgrade

# Remove an app
apk remove firefox
```

### Flatpak

Flatpak is also available:

```bash
# Install Flatpak
apk add flatpak

# Add Flathub remote
flatpak remote-add --if-missing flathub https://flathub.org/repo/flathub.flatpakrepo

# Install an app
flatpak install firefox
```

### Python/pip

```bash
# Install pip
apk add py3-pip

# Install a Python package
pip3 install package_name
```

## Terminal Usage

### Basic Commands

- `pmbootstrap` - PostmarketOS build and maintenance tool
- `sudo` - Administrative privileges (password: `147147`)
- `su` - Switch user
- `reboot` / `shutdown` - System control

### Useful pmcommands

```bash
# Check system info
pmbootstrap info

# List installed packages
pmbootstrap flasher linaro chroot "apk list -I"

# Update system
pmbootstrap os update

# Change UI/desktop
pmbootstrap init  # Re-run init to select different UI

# Enable SSH
pmbootstrap flasher sshd enable

# Check partition layout
pmbootstrap flasher linaro fastboot get_partition_userdata
```

### Shell Shortcuts

- `Ctrl+C` - Cancel current command
- `Ctrl+D` - Exit shell (logout)
- `Ctrl+Z` - Suspend current process
- `!` - History expansion (e.g., `!ls` runs last `ls` command)

## Phone Functionality

### Making Calls & SMS

postmarketOS supports basic telephony on the OnePlus 6, but functionality varies by build:
- Calls: Generally work via the Phosh telephony app
- SMS: Available but may require additional configuration
- Contacts: Sync via Google account or manual entry

**Note:** Some features like VoLTE, VoIP, and carrier settings depend on the specific postmarketOS build and modem configuration.

### Mobile Data

1. Go to Settings → Network & Internet → Mobile network
2. Enable "Mobile data"
3. APN settings are usually auto-configured, but may need manual setup if not connecting

### Wi-Fi

1. Settings → Network & Internet → Wi-Fi
2. Toggle on and select your network
3. Password entry as usual

### Bluetooth

1. Settings → Bluetooth
2. Toggle on and pair with devices
- File transfer: Use `obexftp` or graphical tools
- Tethering: Available as hotspot or PAN

## Camera

The OnePlus 6 camera works postmarketOS, but with limitations:

```bash
# Take a picture from terminal
shotwell or pictures taken with `maim` for screenshots

# Camera app in Phosh should launch
```

Photo storage: `/home/user/Pictures/` or `/var/lib/lp/images/`

## Audio

- Speaker: Works for notifications and audio playback
- Headphone jack: Should auto-detect
- Sound settings: Settings → Sound

## Connecting to External Displays

postmarketOS supports external display output on the OnePlus 6:

```bash
# Using Phosh with external display
# Connect via HDMI/USB-C dock
# The UI should automatically extend or mirror
```

## Battery & Power Management

- Battery status shown in the Phosh top bar
- Power-saving modes available
- Consider installing `tLP` or similar power management tools if battery life is suboptimal

## Backup & Sync

### Important directories
- `/home/user/` - User home directory
- `/home/user/Documents/` - Documents
- `/home/user/Pictures/` - Photos
- `/home/user/.config/` - Application configurations

### Backup using tar

```bash
# Backup home directory
tar -czf postmarketOS-backup.tar.gz /home/user/

# Restore
tar -xzf postmarketOS-backup.tar.gz
```

## Troubleshooting Common Issues

### Screen Flickering or Black Screen
1. Reboot via fastboot: `fastboot reboot`
2. Check if UI needs restart: `pmbootstrap flasher phosh restart`

### No Internet Connection
1. Check Wi-Fi/mobile data settings
2. Try: `nmcli connection up all`
3. Reset network: `pmbootstrap flasher connman restart`

### Apps Crashing
1. Update: `apk upgrade`
2. Reinstall: `apk remove appname && apk install appname`
3. Check compatibility - some Android-only apps won't work

### Bootloop
1. Enter fastboot: `adb reboot bootloader`
2. Re-flash userdata: `fastboot flash userdata oneplus-enchilada.img`
3. Reboot: `fastboot reboot`

## Tips & Tricks

### Speed Up Boot
- Disable unnecessary startup applications in the GUI
- Reduce console resolution if needed

### Increase Storage
- Connect external USB storage via OTG adapter
- Format as ext4 and mount manually

### Remote Administration
```bash
# Enable SSH
pmbootstrap flasher sshd enable

# Connect from computer
ssh user@oneplus6-local-ip

# Or over USB
ssh -p 2222 user@10.15.19.234  # Default pmOS SSH over USB
```

### Screenshot
- GUI: Use the built-in screenshot tool or `gnome-screenshot`
- Terminal: `maim` or `import` from ImageMagick

### Timezone Setup
```bash
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Region/City /etc/localtime
sudo apk add tzdata
```

## References

- [postmarketOS Wiki: OnePlus 6 (oneplus-enchilada)](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada))
- [postmarketOS Documentation](https://wiki.postmarketos.org/wiki/Documentation)
- [Alpine Linux Handbook](https://wiki.alpinelinux.org/wiki/Alpine_Linux)
- [Phosh User Guide](https://wiki.postmarketos.org/wiki/Phosh)