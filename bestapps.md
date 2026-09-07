# Best Apps to Install on OnePlus 6 running postmarketOS

This guide lists the best usable applications to install on the OnePlus 6 when running postmarketOS, organized by category. postmarketOS is based on Alpine Linux, so packages use the `apk` package manager.

**All packages below are verified to exist in Alpine Linux repositories (aarch64).** Always check https://pkgs.alpinelinux.org/packages if unsure.

## Installation Commands

### Using APK (Alpine Package Manager)
```bash
# Search for an app
apk search <app-name>

# Install an app (apk add, NOT "apk install")
sudo apk add <app-name>

# Update all apps
sudo apk update && sudo apk upgrade

# Remove an app
sudo apk del <app-name>
```

### Using Flatpak
```bash
# Install Flatpak
sudo apk add flatpak

# Add Flathub remote
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install a Flatpak app
flatpak install flathub <app-id>
```

### Using Python pip
```bash
# Install pip
sudo apk add py3-pip

# Install a Python package
pip3 install --user <package-name>
```

---

## Productivity

| App | Command | Description |
|-----|---------|-------------|
| **LibreOffice** | `sudo apk add libreoffice` | Full office suite (Writer, Calc, Impress) - best for document editing |
| **GnuCash** | `sudo apk add gnucash` | Personal finance accounting |
| **Geary** | `sudo apk add geary` | Lightweight email client (conversation-based interface) |
| **Evolution** | `sudo apk add evolution` | Full-featured email, calendar, contacts suite |
| **NeoMutt** | `sudo apk add neomutt` | Terminal-based email client - fast, efficient |

### Recommended for OnePlus 6
- **Geary**: Lightweight, works well on small screens
- **NeoMutt**: For power users who live in email (terminal enthusiasts)

---

## Communication

| App | Command | Description |
|-----|---------|-------------|
| **Firefox** | `sudo apk add firefox` | Web browser - best overall experience |
| **Thunderbird** | `sudo apk add thunderbird` | Email + calendar + contacts client |
| **Hexchat** | `sudo apk add hexchat` | IRC client |
| **Chatty** | `sudo apk add chatty` | SMS/messaging app designed for mobile Linux (libpurple-based) |

### Notes
- **Firefox** is essential for web browsing - works well on OnePlus 6 display
- Telegram, Signal, Discord and Slack have **no Alpine packages** - use their web versions in Firefox, or check Flathub for Flatpak builds (Signal: `org.signal.Signal`, Telegram: `org.telegram.desktop`, Discord: `com.discordapp.Discord`). Flatpak apps need more RAM/storage - the OnePlus 6 (6/8 GB) can handle it, but expect slower startup

---

## Media

| App | Command | Description |
|-----|---------|-------------|
| **Megapixels** | `sudo apk add megapixels` | Camera app - the standard postmarketOS camera app |
| **MPV** | `sudo apk add mpv` | Lightweight media player (CLI/GUI) |
| **MPlayer** | `sudo apk add mplayer` | Media player |
| **Pulsemixer** | `sudo apk add pulsemixer` | Audio mixer (CLI) |
| **Grim** | `sudo apk add grim` | Screenshot utility for wlroots-based compositors (Phosh) |

### Camera Notes
- **Megapixels** is the recommended camera app for postmarketOS
- OnePlus 6 camera support is **Partial**: front + both rear cameras work in edge, autofocus support is incomplete
- Photo storage: `~/Pictures/`
- See `using-postmarketOS.md` for camera details

### Fingerprint
The OnePlus 6 fingerprint sensor is **Broken** in mainline Linux (per the wiki hardware table). No app will make it work - do not install `fprintd` expecting functionality.

---

## System Tools

| App | Command | Description |
|-----|---------|-------------|
| **PCManFM** | `sudo apk add pcmanfm` | File manager (lightweight, works well on small screens) |
| **Htop** | `sudo apk add htop` | Interactive process viewer (better than top) |
| **Nano** | `sudo apk add nano` | Terminal text editor |
| **Vim** | `sudo apk add vim` | Powerful terminal text editor |
| **Git** | `sudo apk add git` | Version control |
| **Tree** | `sudo apk add tree` | Directory tree visualizer |

### Remote Access
sshd is **enabled by default** on postmarketOS images - no extra package needed:

```bash
# Connect from computer over USB networking (default address)
ssh user@172.16.42.1

# Or over Wi-Fi
ssh user@oneplus6-local-ip
```

---

## Internet

| App | Command | Description |
|-----|---------|-------------|
| **Firefox** | `sudo apk add firefox` | Web browser (essential) |
| **Netsurf** | `sudo apk add netsurf` | Lightweight web browser (limited JS support) |
| **Links** | `sudo apk add links` | Terminal web browser |

### Web Browsing Tips
- Firefox works well on OnePlus 6 display
- Consider `netsurf` or `links` for lighter browsing if Firefox is too heavy

---

## Development

| App | Command | Description |
|-----|---------|-------------|
| **Neovim** | `sudo apk add neovim` | Modern Vim-based terminal editor |
| **Python3** | `sudo apk add python3` | Python interpreter |
| **Node.js** | `sudo apk add nodejs` | JavaScript runtime |
| **Go** | `sudo apk add go` | Go programming language |
| **Rust** | `sudo apk add rust` | Rust programming language |
| **CMake** | `sudo apk add cmake` | Build system |

### Development Notes
- The OnePlus 6 (aarch64, 6/8 GB RAM) is capable for development
- SSH access enables remote development from your computer
- Kernel development: See the wiki "SDM845 Mainlining" guide

---

## Android Apps

**Anbox is dead and not in Alpine repos - do not use it.** The modern option is:

**Waydroid** (`sudo apk add waydroid`) - container-based Android runtime. Caveats on the OnePlus 6:
- Requires Wayland (Phosh/GNOME/Plasma all qualify)
- Needs Waydroid images from waydroid.org plus some setup
- SDM845 graphics support is good enough for basic apps, but GPU acceleration inside Android may be limited
- Binder/ashmem kernel support: check `zgrep binder /proc/config.gz` on the phone
- Google Play is not included; use F-Droid or APKs from trusted sources

---

## Apps Already Included (Default)

These come pre-installed or are part of the base postmarketOS Phosh setup:

- **File manager**: Minimal default; install `pcmanfm` for full features
- **Terminal**: Built into Phosh
- **Settings**: System configuration
- **Phosh**: Default graphical user interface
- **gnome-software**: App store (Phosh uses this, not gpk-application)
- **Megapixels**: Camera (in most Phosh builds)
- **sshd**: Remote access, enabled by default

---

## How to Discover More Apps

```bash
# Search for available packages
apk search <topic>

# Browse Alpine packages (aarch64!)
# Visit: https://pkgs.alpinelinux.org/packages

# Update package lists
sudo apk update

# Install and verify
sudo apk add <package-name>
apk list -I | grep <package-name>  # Verify installation
```

## Daily Use Commands Summary

```bash
# Update system
sudo apk update && sudo apk upgrade

# Install new app
sudo apk add firefox

# Remove app
sudo apk del firefox

# Search for app
apk search firefox
```

---

## OnePlus 6 Specific Notes

- **Display**: 1080x2280 resolution, apps should scale reasonably
- **Memory**: 6GB/8GB RAM, most modern apps should work fine
- **Storage**: Userdata partition expands to fill disk on first boot
- **Sensors**: Accelerometer/magnetometer/light/proximity work; **fingerprint broken**
- **Modem**: Calls/SMS/data Partial; VoLTE experimental via `81voltd`; single SIM recommended
- **Camera**: Partial support - **Megapixels** is the app to use
- **USB-C**: No DisplayPort alt mode (no video out), no OTG/host mode

---

## References

- postmarketOS Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
- Alpine Packages (aarch64): https://pkgs.alpinelinux.org/packages
- Flathub: https://flathub.org/
- Waydroid: https://waydroid.org/
- postmarketOS Daily Driving: https://wiki.postmarketos.org/wiki/Daily_driving