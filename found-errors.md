>These errors are now fixed!!!


# Found Errors & Inconsistencies in postmarketOS OnePlus 6 Project

## Critical Errors

### 1. `scripts/install-pmosp.sh:48` - Wrong Image Filename
```bash
fastboot flash userdata oneplus-enchilada.img
```
**Problem:** The actual image file produced by pmbootstrap is `userdata.img` (not `oneplus-enchilada.img`). The correct path is typically `$HOME/.local/var/pmbootstrap/installed/images/oneplus-enchilada/userdata.img`.

**Fix:** Use the correct variable/path like in `flash-operations.sh:8`:
```bash
IMG_DIR="$HOME/.local/var/pmbootstrap/installed/images/$DEVICE"
fastboot flash userdata "$IMG_DIR/userdata.img"
```

---

### 2. `scripts/install-pmosp.sh:49` - Missing boot.img Path
```bash
fastboot flash boot boot.img
```
**Problem:** Same issue - `boot.img` is in the pmbootstrap export directory, not current working directory.

**Fix:** Use full path from `IMG_DIR`.

---

### 3. `scripts/install-pmosp.sh:24-28` - Here-Doc Won't Work With pmbootstrap init
```bash
pmbootstrap init <<EOF
$DEVICE
busybox
phosh
EOF
```
**Problem:** `pmbootstrap init` is interactive and prompts for multiple selections. A here-doc with just 3 lines won't work - it expects more inputs (mirror, timezone, encryption, etc.). This will hang or fail.

**Fix:** Either:
- Remove automation and let user run `pmbootstrap init` manually
- Use `pmbootstrap init --device oneplus-enchilada --shell busybox --ui phosh` (check available flags)

---

### 4. `postmarketOSinstallation.md:126` - Wrong Flash Command
```bash
fastboot flash userdata oneplus-enchilada.img
```
**Problem:** Same filename error as script. The image is `userdata.img`, not `oneplus-enchilada.img`.

**Fix:** Change to `userdata.img` and note the correct path.

---

### 5. `postmarketOSinstallation.md:69-70` - Incorrect Linux pmbootstrap Install
```bash
sudo pmbootstrap init
```
**Problem:** Running pmbootstrap as root is explicitly discouraged (see `install-pmosp.sh:17-20` and `setup-check.sh:53-57`). The guide says "sudo" but pmbootstrap should run as regular user.

**Fix:** Remove `sudo` - just `pmbootstrap init`

---

### 6. `postmarketOSinstallation.md:74` - macOS Install Command Wrong
```bash
brew install pmbootstrap
```
**Problem:** pmbootstrap is not in homebrew core. The correct installation is via pip or from source.

**Fix:** 
```bash
pip3 install pmbootstrap
# or
pipx install pmbootstrap
```

---

### 7. `postmarketOSinstallation.md:80` - Windows/WSL Install Wrong
```bash
sudo apt install pmbootstrap
```
**Problem:** pmbootstrap is not in Debian/Ubuntu default repos. Need to add pmbootstrap repo or use pip.

**Fix:**
```bash
pip3 install pmbootstrap
# or follow https://docs.postmarketos.org/pmbootstrap/main/installation.html
```

---

## Inconsistencies

### 8. Default Credentials - Password Discrepancy
- **AGENTS.md:30**, **README.md:51**, **postmarketOSinstallation.md:158**, **using-postmarketOS.md:14**, **quick-ref.md:33-34** all say: `Password: 147147`
- **postmarketOSinstallation.md:158** correctly shows `Password: 147147`
- **BUT** many postmarketOS builds use empty password or different defaults. This should be noted as "default for this build" not universal.

**Suggestion:** Add disclaimer: "Default credentials for standard pmbootstrap Phosh build on OnePlus 6. May vary by build configuration."

---

### 9. File Count Discrepancy - AGENTS.md vs Actual
- **AGENTS.md:13** says `postmarketOSinstallation.md` is 203 lines
- **Actual:** 204 lines (close enough)
- **AGENTS.md:14** says `using-postmarketOS.md` is 275 lines
- **Actual:** 276 lines (close enough)
- **AGENTS.md:21** says `quick-ref.md` is 88 lines
- **Actual:** 89 lines (close enough)
- **AGENTS.md missing:** `README.md`, `bestapps.md`

**Fix:** Update AGENTS.md to include all files and accurate line counts.

---

### 10. Image Path Inconsistency
- `flash-operations.sh:8` correctly uses: `$HOME/.local/var/pmbootstrap/installed/images/$DEVICE`
- `install-pmosp.sh:48-49` uses bare filenames
- `postmarketOSinstallation.md:126,135` uses bare filenames
- `README.md:66` uses `oneplus-enchilada.img`

**Fix:** Standardize all references to use the pmbootstrap export path variable.

---

### 11. Dual Boot Messaging Inconsistent
- `postmarketOSinstallation.md:24-27` says "postmarketOS supports dual-boot but this is officially unsupported"
- `postmarketOSinstallation.md:198` says "Officially unsupported but possible with caution"
- `README.md:72` says "dual-boot unsupported"
- `README.md:73` says "Dual-boot: Officially unsupported"

**Suggestion:** Pick one consistent message. Recommend: "Dual-boot is not officially supported. Proceed with caution and refer to wiki for custom partitioning."

---

### 12. DTBO Erase Timing
- `postmarketOSinstallation.md:59-61` Step 4: Erase dtbo BEFORE pmbootstrap init
- `install-pmosp.sh:41-42` Step 3: Lists dtbo erase as prerequisite
- `flash-operations.sh:64-66` Has it as menu option

**Issue:** The guide order is correct (erase dtbo before flashing), but `install-pmosp.sh` puts it after pmbootstrap install which is fine logically but should verify dtbo was erased.

---

## Script Issues

### 13. `scripts/daily-use.sh:35` - Backup Path Hardcoded
```bash
tar -czf pmosp-backup-$(date +%Y%m%d).tar.gz /home/user/
```
**Problem:** This runs on the HOST computer, not the phone. The phone's `/home/user/` is not accessible at this path on the host.

**Fix:** Either:
- Clarify this script runs on the phone (via SSH)
- Or use `pmbootstrap flasher` commands to backup from host
- Or note: "Run this on the phone via SSH"

---

### 14. `scripts/daily-use.sh:36` - Restore Has Same Issue
```bash
read -p "Backup file: " bfile; tar -xzf "$bfile"
```
**Problem:** Same host vs phone path confusion.

---

### 15. `scripts/daily-use.sh:32` - Package List Command Complex
```bash
pmbootstrap flasher linaro chroot "apk list -I"
```
**Problem:** `linaro` is specific to certain architectures. OnePlus 6 (SDM845) uses `qcom` not `linaro`. This may fail.

**Fix:** Use `pmbootstrap flasher chroot "apk list -I"` or check correct flasher for device.

---

### 16. `scripts/flash-operations.sh:8` - Hardcoded Path May Not Exist
```bash
IMG_DIR="$HOME/.local/var/pmbootstrap/installed/images/$DEVICE"
```
**Problem:** pmbootstrap work directory is configurable. This assumes default.

**Fix:** Use `pmbootstrap config work` to get actual path:
```bash
WORK_DIR=$(pmbootstrap config work)
IMG_DIR="$WORK_DIR/installed/images/$DEVICE"
```

---

### 17. `scripts/setup-check.sh:46` - pmbootstrap config work May Fail
```bash
pmbootstrap_size=$(pmbootstrap config work 2>/dev/null || echo "unknown")
```
**Problem:** If pmbootstrap not initialized, this fails silently. Should check init status first.

---

## Documentation Issues

### 18. `using-postmarketOS.md:170` - Incorrect Camera Command
```bash
shotwell or pictures taken with `maim` for screenshots
```
**Problem:** `shotwell` is a photo manager, not a camera app. `maim` is for screenshots, not camera photos.

**Fix:** 
```bash
# Camera app in Phosh should launch
# Or from terminal: megapixels (if installed)
```

---

### 19. `using-postmarketOS.md:267` - SSH USB IP Hardcoded
```bash
ssh -p 2222 user@10.15.19.234  # Default pmOS SSH over USB
```
**Problem:** This IP (10.15.19.234) is specific to pmbootstrap's USB networking. It may vary. Should explain it's the default USB tethering IP.

**Fix:** Add comment: "Default USB networking IP. Verify with `ip addr` on phone."

---

### 20. `README.md:12-22` - Project Structure Missing Files
The tree doesn't include:
- `README.md` (itself)
- `bestapps.md`
- `found-errors.md` (this file)

---

### 21. `bestapps.md:78` - Anbox Mention May Be Misleading
```bash
sudo anbox install
```
**Problem:** Anbox is not in standard Alpine repos. Requires kernel support (binder, ashmem) which may not be enabled on OnePlus 6 kernel.

**Fix:** Add disclaimer: "Anbox requires kernel modules not typically in OnePlus 6 postmarketOS kernel. Not recommended for beginners."

---

### 22. `bestapps.md:92` - fprintd for Fingerprint
```bash
sudo apk add fprintd
```
**Problem:** OnePlus 6 fingerprint sensor (FPC1025/FPC1035) support in mainline Linux is limited. fprintd may not work.

**Fix:** Add note: "Fingerprint support on OnePlus 6 is experimental. Check wiki for current status."

---

### 23. `postmarketOSinstallation.md:112-114` - Partition Check Command
```bash
pmbootstrap flasher linaro fastboot get_partition_userdata
```
**Problem:** Same `linaro` issue as #15. OnePlus 6 is qcom.

**Fix:** Use `pmbootstrap flasher fastboot get_partition_userdata` (without linaro)

---

### 24. `postmarketOSinstallation.md:164` - Switching UI
```bash
pmbootstrap init  # Re-init to change UI
```
**Problem:** Re-running init requires rebuilding everything. Should mention `pmbootstrap install` after.

**Fix:** 
```bash
pmbootstrap init  # Re-run init to select different UI
pmbootstrap install  # Rebuild with new UI
```

---

## Minor Issues

### 25. `README.md` Title vs Project Name
- File says "postmarketOS OnePlus 6 Installation & Operations"
- AGENTS.md says "postmarketOS OnePlus 6 Project"
- Should be consistent

### 26. `bestapps.md:202-205` References Files That Don't Match
References `scripts/daily-use.sh` for "Update system" but the script uses `pmbootstrap os update` while the guide also mentions `apk upgrade`. Minor inconsistency.

### 27. Typos/Grammar
- `using-postmarketOS.md:18`: "press the Power button 3 times. To return to the GUI, press `Ctrl+Alt+F7`" - Ctrl+Alt+F7 is for PC, not phone
- `postmarketOSinstallation.md:33`: "Use OTA updates or the community `oxygen-updater` app" - oxygen-updater is third-party, should be noted

### 28. Missing Executable Permissions Note
All scripts need `chmod +x scripts/*.sh` but only mentioned in README.md:135. Should be in each script header or AGENTS.md.

---

## Recommendations Priority

### High Priority (Fix First)
1. **#1, #2, #4** - Wrong image filenames in install script and guide
2. **#3** - pmbootstrap init automation won't work
3. **#5, #6, #7** - Incorrect pmbootstrap installation commands per OS
4. **#13, #14** - Backup/restore runs on wrong machine

### Medium Priority
5. **#8** - Credentials disclaimer
6. **#9** - Update AGENTS.md file list
7. **#10** - Standardize image paths
8. **#11** - Consistent dual-boot messaging
9. **#15** - Fix linaro→qcom in flasher commands
10. **#16** - Use dynamic pmbootstrap work dir
11. **#18** - Fix camera command
12. **#24** - Add rebuild step for UI change

### Low Priority
13. **#17** - Setup check robustness
14. **#19** - Document USB IP
15. **#20** - Update README structure
16. **#21, #22** - Add caveats for Anbox/fprintd
17. **#25-28** - Minor consistency/typo fixes

---

## Suggested Quick Fixes

### For `install-pmosp.sh` (Critical):
```bash
# Replace lines 22-50 with:
echo "Step 1: Initialize pmbootstrap for $DEVICE"
echo "----------------------------------------"
echo "Run: pmbootstrap init"
echo "Select: Device=oneplus-enchilada, Shell=busybox, UI=phosh"
read -p "Press Enter after pmbootstrap init completes..."

echo ""
echo "Step 2: Build the postmarketOS image"
echo "----------------------------------------"
pmbootstrap install --fde

WORK_DIR=$(pmbootstrap config work)
IMG_DIR="$WORK_DIR/installed/images/$DEVICE"

echo ""
echo "Step 3: Prepare the device"
echo "----------------------------------------"
echo "Ensure: bootloader unlocked, dtbo erased"
read -p "Press Enter when ready..."

echo ""
echo "Step 4: Flash postmarketOS to phone"
echo "----------------------------------------"
echo "Phone must be in fastboot mode"
fastboot flash userdata "$IMG_DIR/userdata.img"
fastboot flash boot "$IMG_DIR/boot.img"

echo ""
echo "Step 5: First boot"
echo "----------------------------------------"
fastboot reboot
```

### For `flash-operations.sh` (Medium):
```bash
# Replace line 8:
WORK_DIR=$(pmbootstrap config work)
IMG_DIR="$WORK_DIR/installed/images/$DEVICE"
```

### For `postmarketOSinstallation.md` (Critical):
- Line 69: Remove `sudo` from `pmbootstrap init`
- Line 74: Change to `pip3 install pmbootstrap`
- Line 80: Change to `pip3 install pmbootstrap`
- Line 126: Change `oneplus-enchilada.img` → `userdata.img`
- Line 135: Add note about boot.img path

### For AGENTS.md:
- Add `README.md` and `bestapps.md` to file structure

---

# RESOLUTION — 2026-09-07 Audit & Full Correction

A follow-up audit (verified against the official pmbootstrap docs, pmbootstrap source code, the Alpine package index, the Flatpak/NetworkManager docs, and the OnePlus 6 wiki page snapshot in this repo) found **~30 additional errors** — and several errors in this report itself. All files were then fully corrected.

## Corrections to this report (found-errors.md was wrong about)

1. **#1, #2, #4, #10, #16 (image filename claim) — BACKWARDS.** Verified from pmbootstrap source (`pmb/install/_install.py`, `pmb/commands/export.py`): the rootfs image IS named `oneplus-enchilada.img`. There is NO `userdata.img` and NO `~/.local/var/pmbootstrap/installed/images/` directory. Correct flow: `pmbootstrap export` symlinks `oneplus-enchilada.img`, `boot.img` (and initramfs/vmlinuz/dtbo.img) into `/tmp/postmarketOS-export/`. The actual bug in `install-pmosp.sh` was only the missing path, not the filename.
2. **#7 (Windows/WSL fix) — WRONG.** pmbootstrap docs: WSL "does **not** work!", macOS unsupported. Debian now ships `pmbootstrap` (`apt install pmbootstrap` works). The real fix: mark non-Linux hosts unsupported, recommend Linux VM; the guide's `brew`/WSL sections were removed, not converted to pip.
3. **#3 (init flags) — the suggested fix doesn't exist.** `pmbootstrap init` has no `--device/--shell/--ui` flags (only `--shallow-initial-clone`). Fix applied: interactive init with instructions.
4. **#15, #23 (linaro fixes) — the suggested replacements don't exist.** There is no `pmbootstrap flasher chroot` or `flasher fastboot`. Real replacement: run commands on the phone (`apk list -I`, `ls /dev/disk/by-partlabel/`) or via SSH.
5. **#19 (SSH IP) — the "fix" would have blessed a wrong IP.** The real default pmOS USB networking address is `172.16.42.1` (port 22). `10.15.19.234:2222` was wrong (2222 is pmbootstrap's QEMU SSH port).
6. **#13, #14 — invalid.** `scripts/daily-use.sh` was EMPTY (1 byte); the referenced line numbers didn't exist. The script has now been written from scratch (runs on host, operates over SSH).
7. **#26 — both sides wrong.** `pmbootstrap os update` doesn't exist at all; phone updates are `sudo apk update && sudo apk upgrade`.
8. **#21/#22 were too soft.** Anbox is dead (not in repos — replaced with Waydroid notes); fingerprint is **Broken** upstream (not "experimental"), so fprintd was removed from bestapps.md.

## Additional errors found in project files (now fixed)

- **Invented pmbootstrap commands** across all docs: `pmbootstrap os update`, `pmbootstrap flasher sshd enable`, `pmbootstrap flasher connman restart`, `pmbootstrap flasher phosh restart`, `pmbootstrap flasher linaro ...`, `pmbootstrap info`, `pmbootstrap unbrick`, `pmbootstrap os update`-based "Method 1" updates. Real flasher subcommands: boot, flash_kernel, flash_lk2nd, flash_rootfs, flash_vbmeta, flash_dtbo, sideload, list_devices, list_flavors. sshd is enabled by default (`install --no-sshd` to disable).
- **`fastboot flashing unlock`** → wiki documents **`fastboot oem unlock`** for the OnePlus 6.
- **`apk install` / `apk remove`** → `apk add` / `apk del` (~20 occurrences).
- **`flatpak remote-add --if-missing`** → `--if-not-exists`.
- **SSH over USB `ssh -p 2222 user@10.15.19.234`** → `ssh user@172.16.42.1` (port 22; 2222 is QEMU's port).
- **External display over USB-C claimed "supported"** → OnePlus 6 has NO DisplayPort alt mode; USB OTG is Broken (wiki, maintainer quote). Sections removed/rewritten in using-postmarketOS.md, README.md, quick-ref.md.
- **Fabricated Alpine packages in bestapps.md** (verified against pkgs.alpinelinux.org, aarch64): `twitter`, `mastodon`, `signal-desktop`, `slack`, `discord`, `corebird`, `bitmessage`, `retroshare`, `glance`, `pict-see`, `catview`, `fingerterm`, `neofetch`, `anbox` — none exist. Telegram is also not packaged (Flatpak-only). `taskwarrior` is named `task` in Alpine; `obexftp` doesn't exist (removed).
- **`Ctrl+Alt+F7` TTY return + Volume Down/Power×3** — the combo is the `ttyescape` package feature, not built-in; F-key return needs a physical keyboard. Docs rewritten.
- **Camera section gibberish** ("shotwell or pictures taken with maim") — rewritten around Megapixels; `/var/lib/lp/images/` is a Librem path, removed; `/home/user/Pictures/` → `~/Pictures/`.
- **`nmcli connection up all`** — invalid; replaced with `nmcli networking on`.
- **"Phosh uses gpk-application"** — outdated; Phosh uses gnome-software.
- **`pmbootstrap init` here-doc automation** in install-pmosp.sh — init is fully interactive; replaced with instructions + confirmation prompts.
- **setup-check.sh** — bogus "pmbootstrap_size" probe replaced with a real `df`-based free-space check; install hints corrected; Linux-only check added.
- **Hardcoded image dir** in flash-operations.sh — now `/tmp/postmarketOS-export` with work-chroot fallback (`$(pmbootstrap config work)/chroot_native/home/pmos/rootfs/`).
- **Missing dtbo consequence warning** (erasing dtbo makes Android/TWRP unbootable on the current slot) — added everywhere relevant.
- **Missing wiki facts** — added: Wi-Fi US regulatory channels 12/13 issue, 2.4 GHz dropouts, GPS needs SIM+Geoclue, VoLTE via `81voltd` (experimental), single-SIM recommendation, CrashDump mode handling, camera-focus-motor idle-drain workaround, OxygenOS 9.0.8 recommendation for GPS/VoLTE.
- **`brew install pmbootstrap`** — removed (macOS unsupported).
- **README/AGENTS file trees** — now list bestapps.md, found-errors.md, wiki PDF, opencode.json.

## Verification performed

- pmbootstrap subcommand list & flags: official docs (docs.postmarketos.org) + source (gitlab.postmarketos.org)
- Image naming/export dir: pmbootstrap source (`pmb/install/_install.py`, `pmb/commands/export.py`)
- Package existence: pkgs.alpinelinux.org (v3.22, aarch64)
- OnePlus 6 hardware/flash facts: wiki page snapshot PDF (repo) — matches live wiki
- flatpak flag: flatpak-command-reference; nmcli: NetworkManager docs
- Scripts: `bash -n` syntax check + banned-pattern grep (see AGENTS.md "Verified Command Facts")
- Update line counts
- Add note about script executable permissions
