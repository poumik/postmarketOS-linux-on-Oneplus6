# postmarketOS OnePlus 6 Installation & Operations

A comprehensive guide and toolkit for installing and using postmarketOS on the OnePlus 6 (codename: `oneplus-enchilada`).

postmarketOS is a mobile operating system based on mainline Linux, extending the life of devices like the OnePlus 6 which reached End-of-Life in December 2021.

---

## Project Structure

```
/postmarketOSinstallation.md    # 10-step installation guide (203 lines)
/using-postmarketOS.md          # Daily usage guide (275 lines, renamed from .O)
/scripts/
│   ├── install-pmosp.sh        # Automated installation workflow
│   ├── daily-use.sh            # Interactive daily operations menu
│   ├── flash-operations.sh     # Fastboot flashing operations
│   └── setup-check.sh          # Host system readiness verification
/reference/
│   └── quick-ref.md            # Concise command/reference card (88 lines)
/AGENTS.md                      # Agent workflow and project conventions
```

---

## Quick Start

### Prerequisites
- OnePlus 6 device
- Computer with Linux, macOS, or Windows (via WSL)
- USB cable
- Approximately 30-60 minutes

### Installation Steps
1. **Read** `postmarketOSinstallation.md` for full step-by-step guide
2. **Run** `scripts/setup-check.sh` to verify host system readiness
3. **Execute** `scripts/install-pmosp.sh` for automated installation
4. Or manually follow the markdown guide steps 1-10

### Daily Use
1. **Read** `using-postmarketOS.md` for phone usage guidelines
2. **Run** `scripts/daily-use.sh` for interactive menu (update, apps, SSH, backup)
3. Or use individual commands from the quick-ref guide

### Flashing Operations
- Run `scripts/flash-operations.sh` for fastboot operations
- Key: Always use `fastboot reboot`, NEVER power button

### Quick Reference
- View `reference/quick-ref.md` for essential commands
- Default credentials: Username `user`, Password `147147`
- TTY switch: Hold Volume Down + Press Power button 3 times

---

## Installation Guide (`postmarketOSinstallation.md`)

### 10-Step Process
1. **Upgrade OxygenOS** to latest version (recommended) or skip if replacing Android
2. Enable Developer Options (tap Build number 7 times)
3. Enable USB Debugging
4. **Unlock bootloader**: `fastboot flashing unlock`
5. **Erase dtbo partition**: `fastboot erase dtbo` (critical prerequisite)
6. Install pmbootstrap on host computer
7. **Build image**: `pmbootstrap install` or `--fde` for full disk encryption
8. **Flash userdata**: `fastboot flash userdata oneplus-enchilada.img`
9. **First boot**: `fastboot reboot` (do not use power button)
10. **Default credentials**: Username `user`, Password `147147`

### Three Scenarios
- **Erase Android, install postmarketOS only**: Skip OxygenOS upgrade, back up data first
- **Keep Android + postmarketOS**: Upgrade both slots to latest OxygenOS (dual-boot unsupported)
- **Dual-boot**: Officially unsupported, proceed with caution

---

## Daily Usage (`using-postmarketOS.md`)

### System Updates
```bash
pmbootstrap os update
# or
apk update && apk upgrade
```

### Application Installation
```bash
# APK (Alpine Linux packages)
apk search firefox
apk install firefox

# Flatpak
apk add flatpak
flatpak remote-add --if-missing flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install firefox

# Python
apk add py3-pip
pip3 install package_name
```

### Phone Functionality
- **Calls/SMS**: Basic telephony via Phosh app
- **Wi-Fi**: Settings → Network & Internet → Wi-Fi
- **Mobile data**: Settings → Mobile network
- **Bluetooth**: Settings → Bluetooth (file transfer via OBEX FTP)
- **Camera**: Phosh camera app (limitations expected)
- **External display**: USB-C video output supported

### Troubleshooting
- **Bootloop/black screen**: Re-flash `fastboot flash userdata oneplus-enchilada.img`
- **No internet**: `nmcli connection up all` or `pmbootstrap flasher connman restart`
- **Apps crashing**: `apk upgrade` or reinstall

### Backup & Restore
```bash
# Backup home directory
tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/

# Restore from backup
tar -xzf pmosp-backup.tar.gz
```

---

## Scripts (`scripts/` directory)

| Script | Purpose |
|--------|---------|
| `install-pmosp.sh` | Automated installation workflow (5 steps) |
| `daily-use.sh` | Interactive menu (update, apps, SSH, backup) |
| `flash-operations.sh` | Fastboot flashing (userdata, boot, dtbo) |
| `setup-check.sh` | Host system readiness verification |

Make all scripts executable: `chmod +x scripts/*.sh`

---

## Reference (`reference/quick-ref.md`)

Concise command/reference card with:
- Key pmbootstrap, fastboot, and APK commands
- Default credentials and wiki URLs
- Partition layout overview
- Troubleshooting steps
- Phone functionality summary
- Backup commands
- Tips & tricks (boot speed, storage, remote admin, screenshots, timezone)

---

## Agent Workflow (`AGENTS.md`)

### Installation Agents
1. Read `postmarketOSinstallation.md`
2. Run `scripts/setup-check.sh`
3. Execute `scripts/install-pmosp.sh`

### Daily Use Agents
1. Read `using-postmarketOS.md`
2. Run `scripts/daily-use.sh`

### Troubleshooting Agents
1. Check `reference/quick-ref.md`
2. Run `scripts/flash-operations.sh`

Refer to postmarketOS wiki: `wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)`

---

## Safety Warnings ⚠

- **Always use `fastboot reboot`, NEVER the power button** - can corrupt rootfs
- **Back up important data before flashing** (tar backup commands in guides)
- **Ensure dtbo partition is erased** before first flash: `fastboot erase dtbo`
- **Unlock bootloader before installing**: `fastboot flashing unlock`
- **Upgrade OxygenOS to latest version** on both slots (recommended)

### Data Loss Warning
- `fastboot flash userdata` will wipe the userdata partition
- Back up `/home/user/` before major operations
- Use: `tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/`

---

## References

- postmarketOS Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
- pmbootstrap Documentation: https://docs.postmarketos.org/pmbootstrap/main/installation.html
- Installation Guide: https://wiki.postmarketos.org/wiki/Installation
- Default credentials: Username `user`, Password `147147`