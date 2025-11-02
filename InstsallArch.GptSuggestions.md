# Installing Arch Linux (UEFI) + Hyprland
This guide documents a **manual, minimal** Arch install targeted at **UEFI systems with an EFI System Partition (ESP) mounted at `/boot`**. **Secure Boot is not covered.** No helper scripts.

> TL;DR flow: Live USB → Connect internet → Partition (GPT/UEFI) → Mount → `pacstrap` → `genfstab` → `arch-chroot` → Locale/Time/Host → Users/Sudo/NetworkManager → Bootloader (GRUB) → Reboot → First boot checks.

---

## 0) Live USB boot & sanity checks
- Ensure UEFI boot (your firmware menu should show the USB under a UEFI entry).
- Keyboard: `loadkeys sv-latin1` (optional).
- Internet: prefer ethernet. For Wi‑Fi in live env, use `iwctl` or temporarily `nmtui` (see below).  
- Sync time: `timedatectl set-ntp true`

Optional (faster mirrors if downloads are slow):
```bash
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

---

## 1) Partitioning (GPT/UEFI)
Assuming **single‑disk** install `/dev/nvme0n1` (adjust for your device). Target layout:

- **/boot** (ESP): 512–1024 MiB, **FAT32**, **EFI System** flag
- **/** (root): rest of disk, ext4 (no swap), *or* leave space for a swapfile (see §“Optional: Swapfile & hibernation”)

Example (use `fdisk`/`cfdisk`/`gdisk` as you prefer).

Format:
```bash
mkfs.fat -F32 /dev/nvme0n1p1              # ESP
mkfs.ext4 /dev/nvme0n1p2                  # root
```

Mount:
```bash
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

Validate:
```bash
lsblk -f
```

---

## 2) Base install
```bash
pacstrap -K /mnt base linux linux-firmware networkmanager nano vim grub efibootmgr sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

---

## 3) Locale, time, hostname **(inside chroot)**
```bash
# Locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#sv_SE.UTF-8/sv_SE.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf    # English UI; Swedish input still fine

# Time & clock
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc

# Hostname
echo 'forge' > /etc/hostname                  # change if needed

# Hosts
cat >/etc/hosts <<'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   forge
EOF
```

---

## 4) Users, sudo, network **(still in chroot)**
```bash
# Root password
passwd

# User
useradd -m -G wheel -s /bin/bash navid         # change username
passwd navid

# Sudo for wheel
EDITOR=nano visudo    # uncomment: %wheel ALL=(ALL:ALL) ALL

# NetworkManager on first boot
systemctl enable NetworkManager
```

> If you used **systemd-networkd in the live environment**, that was *only* for the installer session. Your installed system will use **NetworkManager**.

---

## 5) Bootloader (GRUB on UEFI)
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

Quick verification:
```bash
efibootmgr -v          # should list a GRUB entry
lsblk -f               # confirm /boot is vfat (FAT32) and mounted
```

---

## 6) Reboot
```bash
exit
umount -R /mnt
reboot
```

---

## 7) First boot checklist
- Log in as your **user** (not root).
- Connect network: `nmtui` or your DE/Wayland network applet.
- Update:
```bash
sudo pacman -Syu
```

---

## Optional: Swapfile & hibernation
If you want swap (e.g., for hibernation), create a swapfile sized to RAM (or more if you hibernate large memory states). Example 16 GiB:
```bash
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
sudo swapon -a
```
> For hibernation you must also set the kernel `resume=` parameter and add a swapfile offset; consult the Arch Wiki.

---

## Notes
- This guide targets **clean UEFI installs**; legacy/BIOS is out of scope.
- Filesystems: ext4 for simplicity; replace with btrfs/xfs if you know why.
- Keep commands copy‑paste‑safe (no `$` prompt char). Spellings double‑checked.
- Next stage (separate doc): **Hyprland & environment setup** (greetd, Waybar, Wofi, audio, BT, gaming notes).

