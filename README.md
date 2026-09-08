> ⚠️ **Disclaimer:** This is an unofficial, community-maintained guide.
> Flashing your device carries risk of data loss or a bricked phone.
> Follow these steps at your own risk. Always back up important data first.
> This project is not affiliated with OnePlus or the postmarketOS project.



# postmarketOS OnePlus 6 Installation & Operations

A comprehensive guide and toolkit for installing and using postmarketOS on the OnePlus 6 (codename: `oneplus-enchilada`).

postmarketOS is a mobile operating system based on mainline Linux, extending the life of devices like the OnePlus 6 which reached End-of-Life in December 2021.

---

## Project Structure

```
├── postmarketOSinstallation.md    # Step-by-step installation guide
├── using-postmarketOS.md          # Daily usage guide
├── headless-server.md             # Phone-as-Linux-server guide (headless)
├── bestapps.md                    # Verified app recommendations
├── found-errors.md                # Error log + resolution notes
├── scripts/
│   ├── install-pmosp.sh           # Automated installation workflow
│   ├── daily-use.sh               # Interactive daily operations menu (over SSH)
│   ├── flash-operations.sh        # Fastboot flashing operations
│   └── setup-check.sh             # Host system readiness verification
├── reference/
│   └── quick-ref.md               # Concise command/reference card
└── AGENTS.md                      # Agent workflow and project conventions
```

---

## Quick Start

### Prerequisites
- OnePlus 6 device
- **Computer with Linux** (pmbootstrap does not support macOS; WSL does not work — use a Linux VM if needed)
- USB cable
- Approximately 30-60 minutes

### Installation Steps
1. **Read** `postmarketOSinstallation.md` for full step-by-step guide
2. **Run** `scripts/setup-check.sh` to verify host system readiness
3. **Execute** `scripts/install-pmosp.sh` for automated installation
4. Or manually follow the markdown guide steps

### Daily Use
1. **Read** `using-postmarketOS.md` for phone usage guidelines
2. **Run** `scripts/daily-use.sh` for interactive menu (update, apps, SSH, backup) — talks to the phone over SSH (`ssh user@172.16.42.1` over USB)
3. Or use individual commands from the quick-ref guide

### Headless Server
1. **Read** `headless-server.md` to run the phone as a screen-off Linux home server
2. Includes SSH setup (USB toggle caveat, mDNS, Wi-Fi), server-mode commands, verified packages, and pitfalls from the AI-assisted install chat (`link-to-installation-chat-with-gemini-ai.md` — use with caution, see its §8 error list)

### Flashing Operations
- Run `scripts/flash-operations.sh` for fastboot operations
- Key: Always use `fastboot reboot`, NEVER the power button

### Quick Reference
- View `reference/quick-ref.md` for essential commands
- Default credentials (standard build, may vary): Username `user`, Password `147147`
- TTY switch: install `ttyescape` on the phone, then hold Volume Down + Press Power button 3 times

---

## Installation Guide (`postmarketOSinstallation.md`)

### Process Overview
1. **Upgrade OxygenOS** to latest version (recommended) or skip if replacing Android
2. Enable Developer Options (tap Build number ~10 times) + USB debugging
3. **Unlock bootloader**: `fastboot oem unlock` (erases all data)
4. **Erase dtbo partition**: `fastboot erase dtbo` (critical prerequisite — makes Android/TWRP unbootable on the slot)
5. Install pmbootstrap on host computer (Linux only)
6. **Build image**: `pmbootstrap install` or `--fde` for full disk encryption, then `pmbootstrap export`
7. **Flash**: `pmbootstrap flasher flash_rootfs` + `flash_kernel`, or manually
   `fastboot flash userdata /tmp/postmarketOS-export/oneplus-enchilada.img`
   `fastboot flash boot /tmp/postmarketOS-export/boot.img`
8. **First boot**: `fastboot reboot` (do not use power button)
9. **Default credentials** (standard build): Username `user`, Password `147147`
10. **Post-install**: update with `sudo apk update && sudo apk upgrade` on the phone; sshd is on by default (`ssh user@172.16.42.1` over USB)

### Three Scenarios
- **Erase Android, install postmarketOS only**: Skip OxygenOS upgrade, back up data first
- **Keep Android + postmarketOS**: Upgrade both slots to latest OxygenOS
- **Dual-boot**: Officially unsupported; proceed with caution (see wiki Multi-booting page)

---

## Daily Usage (`using-postmarketOS.md`)

### System Updates (on the phone)
```bash
sudo apk update && sudo apk upgrade
```
(There is no `pmbootstrap os update`; `pmbootstrap update` only refreshes host build chroots.)

### Application Installation
```bash
# APK (Alpine Linux packages)
apk search firefox
sudo apk add firefox

# Flatpak
sudo apk add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.mozilla.firefox

# Python
sudo apk add py3-pip
pip3 install --user package_name
```

### Phone Functionality (per wiki status table)
- **Calls/SMS**: Partial support; VoLTE experimental (needs `81voltd`)
- **Wi-Fi**: Works, Partial (channels 12/13 blocked by US regulatory default; 2.4 GHz dropouts)
- **Mobile data**: Partial; APN may need manual config
- **Bluetooth**: Works
- **Camera**: Partial — Megapixels is the app to use
- **Sensors**: Accelerometer/magnetometer/light/proximity work; Hall effect broken
- **External display / USB OTG**: NOT supported (no DP alt mode, OTG broken)

### Troubleshooting
- **Bootloop/black screen**: Re-flash from host: `pmbootstrap flasher flash_rootfs && pmbootstrap flasher flash_kernel`, then `fastboot reboot`
- **No internet**: `nmcli networking on`
- **Apps crashing**: `sudo apk upgrade` or reinstall

### Backup & Restore (run ON THE PHONE or via SSH)
```bash
# Backup home directory
tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/

# Pull backup to host
scp user@172.16.42.1:~/pmosp-backup-*.tar.gz .
```

---

## Scripts (`scripts/` directory)

| Script | Purpose |
|--------|---------|
| `install-pmosp.sh` | Automated installation workflow (init → build → export → flash) |
| `daily-use.sh` | Interactive menu over SSH (update, apps, SSH, backup) |
| `flash-operations.sh` | Fastboot flashing (rootfs, boot, dtbo) |
| `setup-check.sh` | Host system readiness verification (Linux only) |

Make all scripts executable: `chmod +x scripts/*.sh`

---

## Reference (`reference/quick-ref.md`)

Concise command/reference card with:
- Verified pmbootstrap, fastboot, and APK commands
- Default credentials and wiki URLs
- SSH-over-USB address (`172.16.42.1`)
- Hardware support status summary
- Troubleshooting steps
- Backup commands

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
- **Ensure dtbo partition is erased** before first flash: `fastboot erase dtbo` — note this makes Android/TWRP unbootable on the current slot
- **Unlock bootloader before installing**: `fastboot oem unlock` (erases all data)
- **Upgrade OxygenOS to latest version** on both slots (recommended; flash 9.0.8 instead if you need GPS/VoLTE)
- **Very old OxygenOS** (e.g. after MSM Download tool): update twice due to A/B partitioning (wiki)

### Data Loss Warning
- `fastboot flash userdata` will wipe the userdata partition
- Back up `/home/user/` before major operations (run on the phone):
  `tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/`

---

## References

- postmarketOS Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
- pmbootstrap Documentation: https://docs.postmarketos.org/pmbootstrap/main/installation.html
- Installation Guide: https://wiki.postmarketos.org/wiki/Installation
- Default credentials (standard build, may vary): Username `user`, Password `147147`


## Disclaimer

This repository is provided "as is", without warranty of any kind.
The author(s) are not responsible for any damage, data loss, or bricked
devices resulting from following these instructions. Flashing custom
firmware voids your device warranty and always carries risk — proceed
only if you understand and accept that risk.
