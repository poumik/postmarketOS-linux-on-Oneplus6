# AGENTS.md - postmarketOS OnePlus 6 Project

This file describes the project structure, conventions, and how to work with agents on this postmarketOS OnePlus 6 installation project.

## Project Overview

A comprehensive guide and toolkit for installing and using postmarketOS on the OnePlus 6 (codename: `oneplus-enchilada`). postmarketOS is a mobile OS based on mainline Linux, extending the life of devices like the OnePlus 6 which reached End-of-Life in December 2021.

## File Structure

```
├── postmarketOSinstallation.md    # Step-by-step installation guide
├── using-postmarketOS.md          # Daily usage guide
├── headless-server.md             # Phone-as-Linux-server guide (headless)
├── bestapps.md                    # Verified app recommendations
├── found-errorsOLD.md                # Error log + resolution notes ( these errors are now fixed )
├── opencode.json                  # opencode agent config
├── scripts/
│   ├── install-pmosp.sh           # Automated installation workflow
│   ├── daily-use.sh               # Interactive daily operations menu (over SSH)
│   ├── flash-operations.sh        # Fastboot flashing operations
│   └── setup-check.sh             # Host system readiness verification
├── reference/
│   └── quick-ref.md               # Concise command/reference card
└── AGENTS.md                      # This file
```

## Conventions

### Markdown Files
- All markdown files use GitHub-flavored markdown
- Code blocks marked with ```bash for shell commands
- Default credentials noted: Username: `user`, Password: `147147` (standard build; may vary by build configuration)
- TTY switch: requires `ttyescape` package on the phone, then hold Volume Down + Press Power button 3 times
- Always end fastboot commands with `fastboot reboot` (never power button)
- Only use commands verified against pmbootstrap docs and the Alpine package index — no invented subcommands or package names

### Verified Command Facts (do not regress these)
- Unlock: `fastboot oem unlock` (OnePlus 6 wiki command; erases all data)
- Rootfs image is `oneplus-enchilada.img` (NOT `userdata.img`); `pmbootstrap export` symlinks it (plus `boot.img`) into `/tmp/postmarketOS-export/`
- Flash with `pmbootstrap flasher flash_rootfs` / `flash_kernel`, or manual `fastboot flash userdata .../oneplus-enchilada.img` + `fastboot flash boot .../boot.img`
- There is NO `pmbootstrap os update`, `pmbootstrap flasher sshd enable`, `pmbootstrap info`, or `pmbootstrap unbrick`
- `pmbootstrap update` only refreshes host build chroot indexes; phone updates are `sudo apk update && sudo apk upgrade`
- sshd is enabled by default in pmOS images; SSH over USB: `ssh user@172.16.42.1`
- Alpine packages are installed with `apk add` (there is no `apk install`); removed with `apk del`
- Flatpak remote flag is `--if-not-exists` (not `--if-missing`)
- macOS and Windows/WSL are NOT supported by pmbootstrap — Linux only
- OnePlus 6 hardware: no USB-C DisplayPort alt mode (no video out), USB OTG broken, fingerprint broken, Hall effect sensor broken, camera/WiFi/GPS/calls Partial
- GPS/VoLTE need OxygenOS 9.0.8 (enchilada) / 9.0.16 (fajita) firmware instead of latest; blank screen after install = firmware never upgraded (wiki "Upgrading firmware without Android installed")
- Build number tap count for Developer Options is ~10 per the wiki (guides commonly say 7; both work)
- Newer pmOS builds (USB rework Dec 2025+) disable USB access by default — SSH needs the phone-side "Secure Shell" toggle; classic images have sshd on by default
- neofetch and macchina are NOT in Alpine repos; use fastfetch (verified)
- Headless server workflow: see `headless-server.md`; the Gemini chat file is a cautionary reference (its error list is §8 there)

### Script Conventions
- All `scripts/*.sh` files use `set -e` for error handling
- Scripts are executable (`chmod +x scripts/*.sh`)
- PS3-based interactive menus for user choices
- Clear section headers and echo statements for readability
- Comments explain each step/section
- `daily-use.sh` runs on the HOST and operates on the phone over SSH (`user@172.16.42.1` by default, overridable as first argument)

### Known-fixed regressions in scripts/ (do not reintroduce)
- `install-pmosp.sh` MUST actually execute `fastboot erase dtbo` before
  flashing — do not reduce this back to a printed reminder only
- `install-pmosp.sh` must not silently apply or silently skip `--fde`;
  ask the user explicitly
- `flash-operations.sh` destructive operations (userdata flash, dtbo
  erase) MUST require a typed "YES" confirmation before running
- `flash-operations.sh` must offer a combined install path where dtbo
  erase cannot be skipped before a userdata flash
- `daily-use.sh` backup/restore MUST clean up the temporary archive in
  /tmp on the phone after transfer
- `daily-use.sh` MUST escape user input (search terms, package names)
  with the `shquote()` helper before embedding it in remote SSH commands
  — never interpolate raw user input into a command string

### bestapps.md conventions
- "Verified" in bestapps.md means the package exists in Alpine repos —
  it does NOT mean the app is touch/phone-screen friendly. Full desktop
  GTK apps (LibreOffice, Evolution, GnuCash, Hexchat, etc.) install and
  run but may have poor touch UX or even broken touch input (confirmed
  for Thunderbird on Phosh, see Pine64 forum). Flag such apps rather
  than presenting them as equivalent to mobile-native ones.

### Naming Conventions
- Scripts use kebab-case: `install-pmosp.sh`, `daily-use.sh`, etc.
- Markdown files use descriptive names without typos (verified: `using-postmarketOS.md`)
- Reference files in `reference/` subdirectory

## Agent Workflow

### Installation Agents
1. **Read** `postmarketOSinstallation.md` for full step-by-step guide
2. **Run** `scripts/setup-check.sh` to verify host system readiness (Linux only!)
3. **Execute** `scripts/install-pmosp.sh` for automated installation
4. **OR** manually follow the markdown guide steps

### Daily Use Agents
1. **Read** `using-postmarketOS.md` for phone usage guidelines
2. **Run** `scripts/daily-use.sh` for interactive menu (update, apps, SSH, backup)
3. **OR** use individual commands from the quick-ref guide

### Troubleshooting Agents
1. **Check** `reference/quick-ref.md` for common commands and solutions
2. **Run** `scripts/flash-operations.sh` for fastboot operations
3. **Refer** to postmarketOS wiki: `wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)` 

## Key Commands Reference

### pmbootstrap Commands (host, Linux only)
```bash
pmbootstrap init                     # Interactive init (select oneplus-enchilada, phosh)
pmbootstrap install [--fde]          # Build postmarketOS image
pmbootstrap export                   # Symlink flashable images to /tmp/postmarketOS-export/
pmbootstrap flasher flash_rootfs     # Flash rootfs image to userdata
pmbootstrap flasher flash_kernel     # Flash boot image
pmbootstrap update                   # Refresh host chroot package indexes (NOT a phone update)
pmbootstrap status                   # Health check / config overview
pmbootstrap config work              # Print work directory path
```

### Fastboot Commands (phone in fastboot mode)
```bash
fastboot oem unlock                  # Unlock bootloader (erases all data)
fastboot erase dtbo                  # Erase dtbo (prerequisite! kills Android on slot)
fastboot flash userdata /tmp/postmarketOS-export/oneplus-enchilada.img
fastboot flash boot /tmp/postmarketOS-export/boot.img
fastboot reboot                      # Reboot (NOT power button!)
```

### Alpine Linux/APK Commands (on the phone)
```bash
apk search firefox                   # Search packages
sudo apk add firefox                 # Install app (apk add, never "apk install")
sudo apk del firefox                 # Remove app
sudo apk update && sudo apk upgrade  # Update all packages
sudo apk add flatpak                 # Install Flatpak
```

## Safety Warnings

⚠ **CRITICAL:**
- Always use `fastboot reboot`, NEVER the power button to reboot - this can corrupt the rootfs
- Back up important data before flashing (tar backup commands in guides)
- Ensure dtbo partition is erased before first flash: `fastboot erase dtbo` — makes Android/TWRP unbootable on the current slot
- Unlock bootloader before installing: `fastboot oem unlock` (erases all device data)
- Upgrade OxygenOS to latest version on both slots before installation (recommended; flash 9.0.8 instead if GPS/VoLTE are needed)
- `fastboot flash userdata` will wipe the userdata partition
- Back up `/home/user/` on the phone before major operations:
  `tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/`

### Verification principle
Before applying any "fix" suggested by an external source (another AI
tool, an issue, a PR) — especially ones about command order, partition
names, or default values — verify it against a primary source first:
the wiki PDF snapshot in this repo, pmaports source, or official
pmbootstrap docs. Do not trust a suggestion just because it sounds
confident or is phrased as "the most important fix." One such
suggestion in this project's history (dtbo erase order) turned out to
contradict the wiki snapshot and would have made the guide wrong if
applied.


## References

- postmarketOS Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
- pmbootstrap Documentation: https://docs.postmarketos.org/pmbootstrap/main/installation.html
- pmbootstrap Usage: https://docs.postmarketos.org/pmbootstrap/main/usage.html
- Installation Guide: https://wiki.postmarketos.org/wiki/Installation
