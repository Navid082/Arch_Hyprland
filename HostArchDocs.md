# Installing Linux Arch and Hyprland
### This document contains in order of how I went about installing Arch Linux and hyprland


## Arch:
### 1. Setup the network in the USB environment.
Create the file 20-wired.network:  
`$ nano /etc/systemd/network/20-wired.network`  
With the following:
  
[Match]  
Name=enp*  
[Network]  
DHCP=yes

---


        - Starta om nätverkstjänsterna:
	systemctl restart systemd-networkd
	systemctl restart systemd-resolved
        
        
### 2. Partitionering.
	Lista alla partitioner med "lsblk".
	använd verktyget "gdisk".
	
	I gdisk, rensa alla partitioner genom att använda expertläge "x".
	i expertmenyn välj "z". Godkänn båda frågor.
	
	Partitionera disken - OBS Ingen swap eftersom VM
    	Använd `fdisk -l` eller `lsblk` för att lista diskarna.
    	Använd sedan `gdisk` för att skapa följande två partitioner på `/dev/vda`:
    		1. `/boot`  -Last sector: +1G	OSB SÄTT RÄTT HEXKOD    - Hex code: ef00
    		2. `/`      -Last sector: Resten av disken		- Hex code: 8300
    		
    		
### 3. Formatera filsystem och montera
    `$ mkfs.fat -F 32 /dev/nvme0n1p1` (/boot partitionen)     - boot måste vara fat32
    `$ mkfs.ext4 /dev/nvme0n1p2` (root partitionen)


	Montera partitioner
    `$ fdisk -l`    - lista partitionerna igen.
    Montera partitionen /mnt/boot för /boot. /mnt för root.
    `$ mount /dev/nvme0n1p2 /mnt`
    `$ mkdir /mnt/boot`
    `$ mount /dev/nvme0n1p1 /mnt/boot
    

### 4. Installation
	`$ pacstrap -K /mnt base linux linux-firmware intel-ucode networkmanager sudo nano`

### 5. Generera fstab
	`$ genfstab -U /mnt >> /mnt/etc/fstab`

	Kontrollera att båda partitionerna finns
	cat /mnt/etc/fstab
	
	
### 6. Hoppa in i chroot
        Sätt den nuvarande tiden som lokaltid.
        `$ ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime`
        
	Synkar klockan till BIOS.
        `$ hwclock --systohc`

        Sätt språk systemet ska ha stöd för:
        `$ nano /etc/locale.gen`  - Avkommentera en_US.UTF-8 UTF-8 och sv_SE.UTF-8 UTF-8
        `$ locale-gen`

        Sätt den systemtext du vill ha.
        `$ echo "LANG=en_US.UTF-8" > /etc/locale.conf`

        Sätt tangentbordslayout för det nya systemet:
        `$ echo "KEYMAP=sv-latin1" > /etc/vconsole.conf`

        Sätt unikt namn för maskinen på ett nätverk:
        `$ echo "forge" > /etc/hostname`
        
    	Set a password for root.
        `$ passwd`

	Bootloader - GRUB
        Installera GRUB ocgh EFI-verktyg
        `$ pacman -S grub efibootmgr`

        Installera grub där du har din efi-system-partition
        `$ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB`

        Generera GRUB-konfigurationen
        `$ grub-mkconfig -o /boot/grub/grub.cfg`
        
        Kontrollera att mikrocode följer med i GRUB
        `$ grep intel-ucode /boot/grub/grub.cfg`
        
        kontrollera att grub är listad som boot option
        `$ efibootmgr`
        
        Lämna chroot, stäng av, ta ut USB-stickan så den ej läses in vid start och Starta.
        `$ exit`
        `$ poweroff`
        

### 7. Lås root
        Skapa ett nytt användarkontot [namn]:
        `$ useradd -m -G wheel -s /bin/bash [namn]`

        Ge kontot ett lösenord:
        `$ passwd [namn]`

        Redigera i /etc/sudoers. 
        Avkommentera raden som ger användare i wheel gruppen behöriget kör vilket kommando de vill:
        `$ EDITOR=nano visudo`
        Denna rad --> %wheel ALL=(ALL:ALL) ALL

        Växla till det nya användarkontot:
        `$ su [namn]`

        Inaktivera root-inloggning genom att låsa root-kontot:
        `$ sudo passwd -l root`
        

### 8. Fixa nätverket IGEN
	- Skapa filen:
        `$ nano /etc/systemd/network/20-wired.network`

        Lägg till följande i filen:
        [Match]
        Name=enp*
        [Network]
        DHCP=yes
        
        - Starta om nätverkstjänsterna:
	systemctl restart systemd-networkd
	systemctl restart systemd-resolved
	
##################################################

### 9. Hyprland
        `$ sudo pacman -S hyprland waybar dunst wofi alacritty tldr tree dysk btop curl`
        Välj pipewire-jack när efterfrågad.
        
        Kopiera över configfilen
        mkdir ~/.config ~/.config/hypr
        `$ cp /usr/share/hypr/hyprland.conf ~/.config/hypr/hyprland.conf`
        
        KONFIGURERING
        Ändra värdet på terminalen till alacritty som terminal under MY PROGRAMS
        ´$ nano ~/.config/hypr/hyprland.conf

        - Ändra kb_layout = en till se under INPUT
        - Satte terminal till $mainMOD + RETURN
        - Satte killactive till $mainMOD + Q
        - Ändra menu(wofi) till $mainMOD + E
        - Ändra filemanager till $mainmod + F
    
    
