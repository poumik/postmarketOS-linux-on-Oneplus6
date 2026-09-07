# OnePlus 6 as a Headless Linux Server (postmarketOS)

This guide covers turning the OnePlus 6 (`oneplus-enchilada`) into a screen-off Linux home server — no desktop, managed over SSH. It is based on the standard installation guide plus a real-world install log (see `link-to-installation-chat-with-gemini-ai.md` for the original AI-assisted chat; **read it with caution** — its "Pitfalls" section below lists what that chat got wrong).

**All packages in this guide are verified in Alpine repos (aarch64).** For a phone that is still running Android, see `using-postmarketOS.md` first — this guide assumes postmarketOS is already installed (or will be, per `postmarketOSinstallation.md`).

---

## 1. Prerequisites

- OnePlus 6 with postmarketOS installed (any UI is fine — you can keep or drop the desktop later)
- Host computer with `fastboot`/`adb` (Linux; macOS works for flashing but pmbootstrap itself is Linux-only)
- USB cable, Wi-Fi network

## 2. Flashing (recap with the server-critical bits)

Follow `postmarketOSinstallation.md` for the full flow. The steps that matter most for a smooth first boot:

```bash
fastboot oem unlock        # if not already unlocked (erases everything)
fastboot erase dtbo        # CRITICAL: skipping this causes a fastboot bootloop
```

Then flash and reboot:

```bash
pmbootstrap flasher flash_rootfs
pmbootstrap flasher flash_kernel
fastboot reboot
```

Or with pre-built images downloaded from https://postmarketos.org/install/ (pick device → release → `phosh` folder, grab `*-enchilada-boot.img` and `*-enchilada.img.xz`, uncompress the .xz, rename for convenience):

```bash
fastboot flash boot linux-boot.img
fastboot flash userdata linux-rootfs.img
fastboot reboot
```

> **Never download images with `curl https://postmarketos.org -o file.img`** — that saves the homepage HTML, not an image (a classic mistake; it leads to `unxz: File format not recognized`). Download via the browser from the official download server, or build your own with pmbootstrap.

### If stuck in a fastboot bootloop after flashing

The active A/B slot or leftover dtbo is the usual cause:

```bash
fastboot set_active a     # try slot a; if it loops again, try: fastboot set_active b
# Thorough dtbo wipe on both slots (fixes bootloops the plain 'erase dtbo' missed):
fastboot erase dtbo_a
fastboot erase dtbo_b
# Then re-flash boot to the active slot and reboot:
fastboot flash boot linux-boot.img
fastboot reboot
```

First boot takes a few minutes (partition expansion, SSH key generation). Default credentials: `user` / `147147` (standard build; may vary).

## 3. Connecting over SSH

### 3.1 New builds: USB access is disabled by default

Recent postmarketOS releases (systemd/usb-moded rework, Dec 2025+) **disable USB networking by default** for security. If SSH says `Connection refused` on a freshly flashed phone, enable SSH/USB from the phone's screen first:

- Settings → look for **"Secure Shell"** (the phone may display the connect command, e.g. `ssh user@oneplus-enchilada`) → toggle **ON**
- And/or select the USB mode (USB tethering / "Tethering") from the notification shade when the cable is plugged in

Classic (OpenRC) images enable sshd by default — no toggle needed.

### 3.2 Addresses to try (in this order)

```bash
# 1. USB networking (classic default address):
ssh user@172.16.42.1

# 2. mDNS name (works on modern builds with Avahi):
ssh user@oneplus-enchilada.local

# 3. Wi-Fi IP (phone and computer on the same network):
ssh user@<phone-wifi-ip>
```

Get the Wi-Fi IP on the phone (Terminal app or on-screen):

```bash
ip addr show wlan0        # look for inet 192.168.x.x
```

> **Troubleshooting Wi-Fi SSH:** if the phone is on Wi-Fi but SSH times out, check that the computer is not on a guest network (AP isolation blocks device-to-device traffic), and that both devices are on the same band/network. Firewall: `sudo ufw allow ssh` if UFW is installed.

### 3.3 If you locked yourself out (screen off, no SSH)

Boot the last-known-good image temporarily without flashing anything:

```bash
fastboot boot linux-boot.img      # boots from memory; nothing is overwritten
```

Or re-flash from scratch (Steps in §2). A USB-C keyboard (if any OTG workaround works) + `Ctrl+Alt+F2` reaches a TTY on some setups — but remember **USB host mode is broken on this device**, so plan on SSH/fastboot for recovery.

## 4. Wi-Fi setup from the terminal

```bash
nmcli device wifi list
sudo nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
```

Note: this phone's Wi-Fi firmware defaults to US regulatory rules — access points on channels 12/13 may never connect (see `using-postmarketOS.md`).

## 5. Server mode: turn the screen off for good

On **systemd** builds (modern releases):

```bash
# Check which init is running:  ps -p 1 -o comm=   (systemd or init/openrc)

sudo systemctl disable greetd     # stop the desktop/lockscreen from starting
sudo reboot
```

After reboot the screen stays dark; the phone runs headless as a server. To get the desktop back:

```bash
sudo systemctl enable greetd
sudo reboot
# one-shot (until next reboot): sudo systemctl start greetd
```

On **OpenRC** builds the equivalent is:

```bash
sudo rc-update del display-manager default   # disable
sudo rc-update add display-manager default   # re-enable
```

> Keep sshd enabled before going headless: `sudo systemctl enable sshd` (systemd) or `sudo rc-update add sshd default` (OpenRC).

## 6. Recommended server packages (all verified in Alpine aarch64)

```bash
sudo apk update
sudo apk add fastfetch        # system info tool (neofetch is NOT in Alpine repos)
sudo apk add tmux             # keep sessions alive across SSH disconnects
sudo apk add docker docker-cli-compose
sudo systemctl enable --now docker    # systemd; OpenRC: sudo rc-update add docker default
sudo apk add samba samba-common-tools   # SMB network share
sudo apk add nginx            # web server
sudo apk add ufw              # firewall (see §7)
sudo apk add distrobox        # Ubuntu/other-distro containers with apt inside
```

Distrobox gives you a real Ubuntu userland (with `apt`) inside postmarketOS:

```bash
sudo apk add distrobox docker
distrobox create -i ubuntu:latest -n ubuntu-server
distrobox enter ubuntu-server    # you now have apt/apt-get
```

## 7. Security basics

```bash
passwd                        # CHANGE the default 147147 password first!
sudo apk add ufw
sudo ufw allow ssh            # BEFORE enabling, or you lock yourself out
sudo ufw allow samba          # only if you use Samba
sudo ufw enable
sudo ufw status verbose
```

- Do **not** port-forward the phone from the router to the internet
- Samba: restrict access in `/etc/samba/smb.conf` with `hosts allow = 192.168. 172.16.42. 127.` and `bind interfaces only = yes`
- Battery safety: a phone left plugged in 24/7 can swell its battery. Use a smart plug/charging schedule, keep it cool, and check the battery periodically. (USB OTG is broken on this device, so it cannot power accessories — which also means no external disks without major hacks.)

## 8. Pitfalls learned from the AI-assisted install chat (Gemini)

The chat in `link-to-installation-chat-with-gemini-ai.md` eventually succeeded, but along the way it made these mistakes — do NOT repeat them:

1. **`curl https://postmarketos.org -o linux-boot.img`** — downloads the homepage HTML, not an image. Result: `unxz: File format not recognized`. Always use the official download page in a browser.
2. **Invented URLs** (`images.postmarketos.org/bghost/...`) — that path does not exist.
3. **Forgot `fastboot erase dtbo`** before flashing — caused the fastboot bootloop in the first place.
4. **`sudo service sshd start`** — not a valid command on Alpine (`service` doesn't exist); then `rc-service` also failed because the device runs **systemd**, not OpenRC. Check `ps -p 1 -o comm=` first, then use the right init commands.
5. **`usb-moded-developer-mode` systemd unit** — does not exist (the chat admitted it). Use the phone's Settings SSH toggle instead.
6. **Password "1243"** — wrong; the default is `147147`.
7. **Rooting via TWRP + Magisk + Linux Deploy** — unnecessary and risky for a pure pmOS server (a wrong-model TWRP image can brick A/B devices). Only relevant if you specifically want Ubuntu *under* Android.
8. **`neofetch`** — not in Alpine repos (use `fastfetch`; `macchina` is also not packaged).
9. **`opencode web`** — the actual opencode CLI command is `opencode serve` (check current docs before use).
10. **"console" server image folder** — stable pmOS releases for this device do not ship a console-only image; install `phosh` and disable the desktop (§5) instead.

## 9. References

- postmarketOS Wiki: OnePlus 6 (oneplus-enchilada) — see PDF/RTF/HTML snapshots in this repo
- Pre-built images: https://postmarketos.org/install/
- USB stack rework announcement: https://postmarketos.org/edge/2025/12/28/USB-framework-rework/
- SSH wiki: https://wiki.postmarketos.org/wiki/SSH
- Installation guide (this repo): `postmarketOSinstallation.md`
- Daily usage (this repo): `using-postmarketOS.md`