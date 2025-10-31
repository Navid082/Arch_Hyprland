# Installing Linux Arch and Hyprland
### This document contains my execution log of how I went about installing Arch Linux.  
Firstly, create a bootable usb-drive with arch .iso. Then boot into that drive through boot settings in your BIOS.  

**Requirements:**  
[Per the arch wiki](https://wiki.archlinux.org/title/Installation_guide)  
1. A x86_64-compatible machine.  
2. Minimun of 512 MiB RAM.  
3. 2 GiB of disk space.  
4. Internet connection  

---  


### 0. Initial setup: 
`loadkeys sv-latin1` - Load swedish keyboard.  
`setfont ter-132b` - Set bigger font.  
`timedatectl set-timezone Europe/Stockholm` - Set correct timezone.  

---

### 1. Setup the network in the USB environment.  
Create the file 20-wired.network:  
`$ nano /etc/systemd/network/20-wired.network`  
Enter the following content:  
[Match]  
Name=enp*  
[Network]  
DHCP=yes  
  
Restart the network services so that it loads the changes:  
`systemctl restart systemd-networkd`  
`systemctl restart systemd-resolved`  

**Will use Network Manager instead of systemd when installation is finished**  

--- 

### 2. Diskmanagement. 
**OBS No SWAP implemented in this installation process. But highly recommended for hibernation**  

`fdisk -l` - Show detailed disk info.  
`lsblk` - Show disk overview  
`gdisk` - Partition tool  

**OPTIONAL, WIPE DISK:**  
`gdisk /dev/sdx`    
`x`  
`z`  
`y`  
`y`

**Create partitions:**  
List disks `fdisk -l` or `lsblk`.  
Then use `gdisk` to create the following two partitions on your drive:  

| Partition | Size | Code | Purpose |
|---|---|---|---|
| 1 | +1GB | ef00 | /boot|
| 2 | rest | 8300(default) | root |             


**Format filesystems on each partition:**     
`$ mkfs.fat -F 32 /dev/nvme0n1p1`       - Format boot-partition to fat32  
`$ mkfs.ext4 /dev/nvme0n1p2`            - Format root-partition to ext4  

**Mount partitions:**
`$ fdisk -l`                            - list all partitions.  
`$ mount /dev/nvme0n1p2 /mnt`           - /mnt for root.  
`$ mkdir /mnt/boot`                     - Create dir for boot
`$ mount /dev/nvme0n1p1 /mnt/boot`      - /mnt/boot for /boot
`lsblk`                                 - Verify mountpoints.
    
---

### 3. Installation  
**Base system install**  
`$ pacstrap -K /mnt base linux linux-firmware intel-ucode`  - amd-ucode for amd processor.


---

### 4. Generera fstab
`$ genfstab -U /mnt >> /mnt/etc/fstab`  - Write auto-mounts to file

`cat /mnt/etc/fstab`                    - Verfy UUIDs and mountpoints are correct  

---  

### 5. Chroot
`arch-chroot /mnt`                      - Enter into installation directory  

`$ ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime`  - Set current time as localtime  

`$ hwclock --systohc`                   - Sync clock to BIOS

Set system language support:  
`$ nano /etc/locale.gen`                - Uncomment `en_US.UTF-8 UTF-8` and `sv_SE.UTF-8 UTF-8`  

`$ locale-gen`                          - Activates language characters for chosen languages  

`$ echo "LANG=en_US.UTF-8" > /etc/locale.conf`          - Set system language

`$ echo "KEYMAP=sv-latin1" > /etc/vconsole.conf`        - Set keyboardlayout  

`$ echo "forge" > /etc/hostname`        - Name machine "forge"  

`$ passwd`                              - Set password for root-user.


**Bootloader - GRUB**  
`$ pacman -S grub efibootmgr`           - Install GRUB and EFI-tools  

`$ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB`  - Install GRUB in /boot  

`$ grub-mkconfig -o /boot/grub/grub.cfg`        - Genererate GRUB-configuration

`$ grep intel-ucode /boot/grub/grub.cfg`        - Confirm microcode is included

`$ efibootmgr`                                  - Confirm GRUB is listed as boot-option

`$ exit`                                        - Exit chroot

`$ poweroff`                                    - Shutdown system and remove USB-drive

**Start system, choose Arch in GRUB meny and log into `root` with the password you set**
        
---

### 6. Setup base environment
- Install necessary packages:
`sudo pacman -S networkmanager sudo nano`  

- Lock root-user  
After this step use only the new account you created.  

`$ useradd -m -G wheel -s /bin/bash [name]`     - Create a new user account

`$ passwd [name]`                               - Set password

`$ EDITOR=nano visudo`                          - Uncomment this row: `%wheel ALL=(ALL:ALL) ALL`

`$ su [name]`                                   - Change into the new user-account

`$ sudo passwd -l root`                         - deactivate login into root account
        
- Network setup

**Option 1:** NetworkManager (recommended)  
`systemctl enable --now NetworkManager`         - Check spelling. Enable for start at system boot.  
`nmtui`                                         - Connect wifi/ethernet

**Option 2:** systemd-networkd (wired)  
`$ nano /etc/systemd/network/20-wired.network`  - Create this file  
With this content:  
[Match]  
Name=enp*  
[Network]  
DHCP=yes  
        
`systemctl restart systemd-networkd`             - Restart network services  
`systemctl restart systemd-resolved`

---

### 7. Hyprland
- Install packages:  
`$ sudo pacman -S hyprland waybar dunst wofi alacritty tldr tree dysk btop curl eza`  
Choose `pipewire-jack` when prompted.  

--- 

- Configuration file  
Default configuration file might not be copied over to `~/.config/`  
Copy them over:  
`mkdir ~/.config ~/.config/hypr`  
`cp /usr/share/hypr/hyprland.conf ~/.config/hypr/hyprland.conf`