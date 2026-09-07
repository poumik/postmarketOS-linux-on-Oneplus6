# Best Apps to Install on OnePlus 6 running postmarketOS

This guide lists the best usable applications to install on the OnePlus 6 when running postmarketOS, organized by category. postmarketOS is based on Alpine Linux, so packages use the `apk` package manager.

## Installation Commands

### Using APK (Alpine Package Manager)
```bash
# Search for an app
apk search <app-name>

# Install an app (may require sudo)
sudo apk install <app-name>

# Update all apps
apk upgrade
```

### Using Flatpak
```bash
# Install Flatpak
apk add flatpak

# Add Flathub remote
flatpak remote-add --if-missing flathub https://flathub.org/repo/flathub.flatpakrepo

# Install a Flatpak app
flatpak install <app-id>
```

### Using Python pip
```bash
# Install pip
apk add py3-pip

# Install a Python package
pip3 install <package-name>
```

---

## Productivity

| App | Command | Description |
|-----|---------|-------------|
| **LibreOffice** | `sudo apk add libreoffice` | Full office suite (Writer, Calc, Impress) - best for document editing |
| **GnuCash** | `sudo apk add gnucash` | Personal finance accounting |
| **Geary** | `sudo apk add geary` | Lightweight email client (conversation-based interface, Gmail-like) |
| **Evolution** | `sudo apk add evolution` | Full-featured email, calendar, contacts suite - good for GNOME users |
| **NeoMutt** | `sudo apk add neomutt` | Terminal-based email client - fast, efficient for triage |
| **Glance** | `sudo apk add glance` | Minimal email client for postmarketOS Phosh |
| **Taskwarrior** | `sudo apk add taskwarrior` | Command-line task manager |
| **Fingerterm** | `sudo apk add fingerterm` | Simple terminal for phone |

### Recommended for OnePlus 6
- **Geary**: Lightweight, Gmail-like interface, works well on small screens
- **NeoMutt**: For power users who live in email (terminal enthusiasts)
- **Taskwarrior**: Excellent for getting things done without leaving the terminal

---

## Communication

| App | Command | Description |
|-----|---------|-------------|
| **Firefox** | `sudo apk add firefox` | Web browser - best overall experience |
| **Twitter** | `sudo apk add twitter` | Twitter client (official) |
| **Mastodon** | `sudo apk add mastodon` | Mastodon federated social media |
| **Telegram Desktop** | `sudo apk add telegram` | Messaging app with client-side encryption |
| **Signal Desktop** | `sudo apk add signal-desktop` | Secure messaging |
| **Slack** | `sudo apk add slack` | Team collaboration/chat |
| **Discord** | `sudo apk add discord` | Chat/voice platform |
| **Geary** | `sudo apk add geary` | Also serves as lightweight email client |

### Notes
- **Firefox** is essential for web browsing - works well on OnePlus 6 display
- **Telegram/Signal** for messaging - both have desktop clients available via Alpine repos
- **Anbox** (not in standard repos) would be needed for Android apps: `sudo anbox install` (advanced, may not work on all OnePlus 6 builds)

---

## Media

| App | Command | Description |
|-----|---------|-------------|
| **Megapixels** | `sudo apk add megapixels` | Camera app - best available for postmarketOS/PinePhone, works on OnePlus 6 |
| **Pict-See** | `sudo apk add pict-see` | Photo viewer |
| **CatView** | `sudo apk add catview` | Image viewer (terminal-based) |
| **MPlayer** | `sudo apk add mplayer` | Media player |
| **MPV** | `sudo apk add mpv` | Lightweight media player (terminal/CLI) |
| **Pulsemixer** | `sudo apk add pulsemixer` | Audio mixer (CLI) |
| **Fprintd** | `sudo apk add fprintd` | Fingerprint support (OnePlus 6 has fingerprint sensor) |

### Camera Notes
- **Megapixels** is the recommended camera app for postmarketOS
- Works on OnePlus 6 (`oneplus-enchilada`) but may have limitations
- Photo storage: `/home/user/Pictures/` or `/var/lib/lp/images/`
- See `using-postmarketOS.md` for camera details

---

## System Tools

| App | Command | Description |
|-----|---------|-------------|
| **PCManFM** | `sudo apk add pcmanfm` | File manager (lightweight, works well on small screens) |
| **CatView** | `sudo apk add catview` | Image viewer (terminal-based) |
| **Neofetch** | `sudo apk add neofetch` | Display system info in terminal |
| **Htop** | `sudo apk add htop` | Interactive process viewer (better than top) |
| **Nano** | `sudo apk add nano` | Terminal text editor |
| **Vim** | `sudo apk add vim` | Powerful terminal text editor |
| **Git** | `sudo apk add git` | Version control |
| **SSH** | `pmbootstrap flasher sshd enable` + `sudo apk add openssh` | SSH server for remote access |
| **Tree** | `sudo apk add tree` | Directory tree visualizer |

### Remote Access
```bash
# Enable SSH (from guides)
pmbootstrap flasher sshd enable

# Connect from computer
ssh user@oneplus6-local-ip

# Or over USB (default pmOS SSH port)
ssh -p 2222 user@10.15.19.234
```

---

## Internet

| App | Command | Description |
|-----|---------|-------------|
| **Firefox** | `sudo apk add firefox` | Web browser (already listed above, essential) |
| **Thunderbird** | `sudo apk add thunderbird` | Email+calendar+contacts client |
| **Hexchat** | `sudo apk add hexchat` | IRC client |
| **Corebird** | `sudo apk add corebird` | Twitter client (desktop) |
| **Retroshare** | `sudo apk add retroshare` | Secure P2P communication |
| **Bitmessage** | `sudo apk add bitmessage` | P2P encrypted messaging |

### Web Browsing Tips
- Firefox works well on OnePlus 6 display
- Consider using `netsurf` or `links` for lighter browsing if Firefox is too heavy
- `sudo apk add netsurf` or `sudo apk add links`

---

## Development

| App | Command | Description |
|-----|---------|-------------|
| **Neovim** | `sudo apk add neovim` | Modern Vim-based terminal editor |
| **Python3** | `sudo apk add python3` | Python interpreter |
| **Git** | `sudo apk add git` | Version control (already listed) |
| **Node.js** | `sudo apk add nodejs` | JavaScript runtime |
| **Go** | `sudo apk add go` | Go programming language |
| **Rust** | `sudo apk add rust` | Rust programming language |
| **cmake** | `sudo apk add cmake` | Build system |
| **pmbootstrap** | Already installed! | PostmarketOS build and maintenance tool |

### Development Notes
- The OnePlus 6 (`oneplus-enchilada`) is well-supported for development
- `pmbootstrap` is the primary tool for building/installing postmarketOS
- Kernel development: See `postmarketOS Wiki` / `SDM845 Mainlining` guide
- SSH access enables remote development from computer

---

## Apps Already Included (Default)

These come pre-installed or are part of the base postmarketOS Phosh setup:

- **File manager**: Minimal default; install `pcmanfm` for full features
- **Terminal**: Built into Phosh
- **App drawer**: Default application menu
- **Settings**: System configuration
- **Phosh**: Default graphical user interface
- **Firefox**: Included in base install (verify with `apk list -I`)

---

## How to Discover More Apps

```bash
# Search for available packages
apk search <topic>

# Browse Alpine packages
# Visit: https://pkgs.alpinelinux.org/packages

# Update package lists
apk update

# Install and verify
sudo apk install <package-name>
apk list -I <package-name>  # Verify installation
```

## From the Project Files

The existing guides reference these app categories:
- `using-postmarketOS.md`: APK, Flatpak, Python/pip installation methods
- `reference/quick-ref.md`: Package management, troubleshooting
- `scripts/daily-use.sh`: Update system (`pmbootstrap os update` / `apk upgrade`)

## Daily Use Commands Summary

```bash
# Update system
pmbootstrap os update
# or
apk upgrade

# Install new app
sudo apk install firefox

# Remove app
apk remove firefox

# Search for app
apk search firefox
```

---

## OnePlus 6 Specific Notes

- **Display**: 1080p resolution, apps should scale reasonably
- **Memory**: 6GB/8GB RAM, most modern apps should work fine
- **Storage**: Userdata partition expands to fill disk on first boot
- **Sensors**: Fingerprint, accelerometer, gyroscope may have varying support
- **Modem**: Mobile data connectivity works but may require APN configuration
- **Camera**: OnePlus 6 camera works but with postmarketOS limitations - **Megapixels** is the best available app

---

## References

- postmarketOS Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
- Alpine Packages: https://pkgs.alpinelinux.org/packages
- postmarketOS Daily Driving: https://wiki.postmarketos.org/wiki/Daily_driving
- PMOS App Installation: https://liliputing.com/how-to-install-apps-in-postmarketos-with-phosh-shell/