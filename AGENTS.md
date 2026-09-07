# AGENTS.md - postmarketOS OnePlus 6 Project

This file describes the project structure, conventions, and how to work with agents on this postmarketOS OnePlus 6 installation project.

## Project Overview

A comprehensive guide and toolkit for installing and using postmarketOS on the OnePlus 6 (codename: `oneplus-enchilada`). postmarketOS is a mobile OS based on mainline Linux, extending the life of devices like the OnePlus 6 which reached End-of-Life in December 2021.

## File Structure

```
/home/user/Code/Oneplus6/
├── postmarketOSinstallation.md    # 10-step installation guide (203 lines)
├── using-postmarketOS.md          # Daily usage guide (275 lines, renamed from .O)
├── scripts/
│   ├── install-pmosp.sh           # Automated installation workflow
│   ├── daily-use.sh               # Interactive daily operations menu
│   ├── flash-operations.sh        # Fastboot flashing operations
│   └── setup-check.sh             # Host system readiness verification
├── reference/
│   └── quick-ref.md               # Concise command/reference card (88 lines)
└── AGENTS.md                      # This file
```

## Conventions

### Markdown Files
- All markdown files use GitHub-flavored markdown
- Code blocks marked with ```bash for shell commands
- Default credentials noted: Username: `user`, Password: `147147`
- TTY switch: Hold Volume Down + Press Power button 3 times
- Always end fastboot commands with `fastboot reboot` (never power button)

### Script Conventions
- All `scripts/*.sh` files use `set -e` for error handling
- Scripts are executable (`chmod +x scripts/*.sh`)
- PS3-based interactive menus for user choices
- Clear section headers and echo statements for readability
- Comments explain each step/section

### Naming Conventions
- Scripts use kebab-case: `install-pmosp.sh`, `daily-use.sh`, etc.
- Markdown files use descriptive names without typos (verified: `using-postmarketOS.md`)
- Reference files in `reference/` subdirectory

## Agent Workflow

### Installation Agents
1. **Read** `postmarketOSinstallation.md` for full step-by-step guide
2. **Run** `scripts/setup-check.sh` to verify host system readiness
3. **Execute** `scripts/install-pmosp.sh` for automated installation
4. **OR** manually follow the markdown guide steps 1-10

### Daily Use Agents
1. **Read** `using-postmarketOS.md` for phone usage guidelines
2. **Run** `scripts/daily-use.sh` for interactive menu (update, apps, SSH, backup)
3. **OR** use individual commands from the quick-ref guide

### Troubleshooting Agents
1. **Check** `reference/quick-ref.md` for common commands and solutions
2. **Run** `scripts/flash-operations.sh` for fastboot operations
3. **Refer** to postmarketOS wiki: `wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)`

## Key Commands Reference

### pmbootstrap Commands
```bash
pmbootstrap init           # Initialize device port
pmbootstrap install      # Build and install postmarketOS
pmbootstrap install --fde # Full disk encryption install
pmbootstrap os update    # Update system
pmbootstrap flasher sshd enable  # Enable SSH
pmbootstrap info         # System information
```

### Fastboot Commands
```bash
fastboot flashing unlock     # Unlock bootloader
fastboot erase dtbo          # Erase dtbo (prerequisite!)
fastboot flash userdata xxx  # Flash system partition
fastboot flash boot xxx      # Flash kernel/boot
fastboot reboot              # Reboot (NOT power button!)
```

### Alpine Linux/APK Commands
```bash
apk search firefox   # Search packages
apk install firefox  # Install app
apk upgrade          # Update all apps
flatpak install firefox  # Install via Flatpak
```

## Safety Warnings

⚠ **CRITICAL:**
- Always use `fastboot reboot`, NEVER the power button to reboot - this can corrupt the rootfs
- Back up important data before flashing (tar backup commands in guides)
- Ensure dtbo partition is erased before first flash: `fastboot erase dtbo`
- Unlock bootloader before installing: `fastboot flashing unlock`
- Upgrade OxygenOS to latest version on both slots before installation (recommended)

⚠ **Data Loss Warning:**
- `fastboot flash userdata` will wipe the userdata partition
- Back up `/home/user/` directory before major operations
- Use `tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/` for backup

## References

- postmarketOS Wiki: https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)
- pmbootstrap Documentation: https://docs.postmarketos.org/pmbootstrap/main/installation.html
- Installation Guide: https://wiki.postmarketos.org/wiki/Installation