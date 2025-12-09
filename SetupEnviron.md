'# Setting up the new environment
This document does not contain any config files. It shows only how I went about setting setting everything up.


Take a look inte this:  
https://github.com/hyprland-community/awesome-hyprland?tab=readme-ov-file


## Setup ##
Packages installed together with hyprland (See HostArchDocs):
- [X] alacritty
- [X] tldr
- [X] tree
- [X] dysk
- [X] btop
    - [X] rocm-smi - (AMD) for displaying gpu in btop  
- [X] glances
- [X] curl
- [X] dunst

waybar and wofi are configured below. Config files are not explored here.
Dunst is installed but not configured.


Packages installed later
- [X] man-db
- [X] discord
- [X] spotify
- [X] pavucontrol
- [X] 7zip
- [X] libreoffice-still
- [X] eye of gnome
- [X] vim
- [X] docker
- [X] git
- [X] eza - satte detta som alias i bashrc
- [X] bat - nicer cat
- [X] kvm/qemu + virt-manager - Ska jag dokumentera detta här eller i egen fil?
- [X] pipewire pipewire-pulse pipewire-alsa wireplumber
- [X] thunar - set to dark mode in hyprland.conf https://wiki.archlinux.org/title/GTK
- [X] thunderbird for emails.
- [X] Steam
- [X] Heroic Games Launcher
- [X] AppImageLauncher 


Other
- [X] Keybinding. Break out your bindings to a seperate file.
- [X] Grub. changed to menu style hidden and timeout to 0 for faster boot process.
- [~] curl wttr.in - Ska jag lägga till denna i waybar? (Inkluderat med hyprpanel)
- [X] Lägg till vad för dag det är i waybar klockan.


Todo:
- [~] waybar configured but swapped with hyprpanel.
- [ ] Skärmdelning
- [X] USB ska kunna gå att läsa
- [~] Power menu - se 2 script i home foldern. Includerat med hyprpanel
- [X] rsync  
§- [X] docker 
    [X] lazydocker  
    Båda installerade på laptop. Ej lekt med de än
- [X] git
    [X] lazygit
- [X] pacseek
- [ ] trashcan: https://wiki.archlinux.org/title/Trash_management
- [ ] Disk usage. See file/map sizes etc. GUI or TUI.



- [ ] WAKE ON LAN:  
        Stationära går inte att ansluta till när den är i suspend.  
        Satt wake on till "g". Men den sover för djupt. Nätverkskortet stängs av.  
        Det går att ansluta när datorn är igång.  

        `cat /sys/power/mem_sleep`  
        [s2idle] deep   -> detta är problemet. Shallow sleep kommer lösa det. 



--------------------------------------------------
- [X] Hyprland
- Install packages:  
`$ sudo pacman -S hyprland waybar dunst wofi alacritty tldr tree dysk btop curl eza`  
Choose `pipewire-jack` when prompted.

- Configuration file  
Default configuration file might not be copied over to `~/.config/`  
Copy them over:  
`mkdir ~/.config ~/.config/hypr`  
`cp /usr/share/hypr/hyprland.conf ~/.config/hypr/hyprland.conf`

---

- [X] SWAP  
Setting up swap-file not a swap-partition. To gain benefits of hibernation.  
Needs as much size as there is RAM. 32GiB RAM = 32GiB swap-file.  
Kernel kommer försöka komprimera men finns inte garantier att det lyckas.  

`mkswap -U clear --size 32G --file /swapfile`   - Skapande 32GiB swapfil                     
`sudo chmod 600 /swapfile`                      - Säkra filen  
`sudo swapon /swapfile`                         - Aktivera            

`swapon --show`                                 - Verifiera  
`free -h`  
  
`echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab`   - Lägg till en post för swapfile i fstab  
`cat /etc/fstab`                                - Verifiera  

---

- [x] greetd + tuigreet (loginscreen + hyprland autostart)   
**Double check user in /etc/passwd**
`sudo pacman -S greetd-tuigreet`  

Edit `/etc/greetd/config.toml` with the following:  

`[terminal]`  
`vt = 1`  
`[default_session]`  
`command = "tuigreet --time --cmd hyprland"`  
`user = "greeter"`  

Straight after greetd tuigreet is set edit bashrc for simple logout

Personally I logout by typing `logout` in the terminal.  
Do the same by editing `~/.bashrc` and add the following alias:  
`alias logout ="hyprctl dispatch exit"`

--- 

- [x] waybar  
Config files not in homefolder, copy them there:  
`mkdir -p ~/.config/waybar`  
`cp /etc/xdg/waybar/config ~/.config/waybar/`  
`cp /etc/xdg/waybar/style.css ~/.config/waybar/`  

create a new file in **~/.config/hypr/:**  
`nano autostart.conf` with the following content:  
`exec-once = waybar`  

In **~/.config/hypr/hyprland.conf**, under the segment "Autostart" write:  
`source = ~/.config/hypr/autostart.conf`  
This will autostart waybar whenever hyprland executes. i.e when logging in.  

---

- [X] hyprpanel
Basic install. Set to autostart through hyprland config.
Added api key for weather request

- [x] swaybg (wallpaper)
In **~/.config/hypr/autostart.conf** add the following:  
`exec-once = swaybg -c 000000` which will set background to black at login.  

For monitor specific wallpaper:  
List your monitors: `hyprctl monitors` : take note of monitor ID  
Mine is set to:  
`exec-once = swaybg -o DP-1 -i ~/Pictures/Wallpapers/mt3.jpg` # Main screen  
`exec-once = swaybg -o HDMI-A-1 -c 000000` # Secondary screen  

---

- [x] swaylock (lockscreen)                         - Might change to hyprlock? https://github.com/hyprwm/hyprlock?tab=readme-ov-file
Swaylock per default have a bright grey lockscreen.
I set mine to black with keybinding.  
Edit `**~/.config/hypr/hyprland** under **KEYBINDS** add the follwing:  

`bind = $mainMod, L, exec, swaylock -c 000000`

---

- [X] wl-clipboard - Går redan klippa och klistra.  
`echo "hej" | wl-copy` - kopierar stdout  
`wl-paste`  - paste "hej" from clipboard"  

ex:  
`ls -l | wl-copy`  
`wl-paste > fil.txt`  

---

- [x] alacritty / kitty
Installed font for alacritty: `ttf-jetbrains-mono-nerd`  
create and config in ~/.config/alacritty/alacritty.toml  
**Starship:**  
Following the "guide" from the official site: https://starship.rs/guide/  
1. curl -sS https://starship.rs/install.sh | sh
2. Added the following to the end of `~/.bashrc`:  
`eval "$(starship init bash)"`  
**eza:**  
Tried Omarchy, liked how it displayed `ls`. I did the same.  
1. Install eza.  
2. Add the following alias to `~/.bashrc`:
alias ls="eza -lh --group-directories-first --icons=auto"

---

- [x] wofi (menu)  
Edit `**~/.config/hypr/hyprland:**  
1. Under **MY PROGRAMS** add the follwing:  
`$menu = wofi --show drun --sort-order=alphabetical`  
2. Under **KEYBINDS** set the follwing:  
`bind = $mainMod, E, exec, $menu`  

- Hiding elements in wofi menu:  
Wofi menu lists some unwanted applications. Needed for the system. But not used by me directly.  
Like many programs. Wofi looks for files,  
firstly in `~/.local/share/application/`.  
Secondly in `/usr/share/application`.  
if there are no files in `.local/share/application/` it will use the ones in `/usr/share/application/`.  
Dont edit the files in `/usr/share/application/`. Instead copy over the corresponding files to `~/.local/share/application/`  
`cp /usr/share/application/<file.desktop> ~/.local/share/application`  
Add `Hidden=true` to the end of each .desktop-file you want hidden in `/usr/share/applications/`:  
`echo "Hidden=true" | sudo tee -a file.desktop`  

Files I hidden from wofi:  
- avahi-discover.desktop
- bssh.desktop
- bvnc.desktop
- qv4l2.desktop 
- qvidcap.desktop
- remote-viewer.desktop
- xgps.desktop 
- xgpsspeed.desktop

---

- [X] Lägg till två extra diskar.  
Lista alla diskar och partitioner:  
`lsblk`  

notera diskar och partitioner. Det står inte men dess fulla namn är /dev/***. Ex /dev/sdb för hela disken eller /dev/sdb1 för partitionen.  

Skapa monteringspunkt:  
`sudo mkdir /data`  

montera disken dit - disken måste ha ett filsystem först:  
Om disken har gamla partitioner: rensa med sudo `gdisk` /dev/sdx (x → z → y → y) eller skapa ny partition med `n` i `gdisk`.
`sudo mkfs.ext4 /dev/sdb1`  
`sudo mount /dev/sdb1 /data`  
kolla så att det fungerar med `lsblk`  


`sudo blkid /dev/sdb1` kopiera UUID utan citattecken:  
Lägg in i `/etc/fstab`  
# /dev/sdb1  
UUID=<UUID för partitionen här>   /data   ext4   defaults   0   2

Ladda om och testa:  
`sudo systemctl daemon-reload`  
`sudo mount -a`  

Verifiera:  
`lsblk`

Byt ägarskap (om root ska äga men användare ska skriva):  
Kontrollera grupper med `groups`  
`sudo chown root:<rätt grupp> /data`  
`sudo chmod 775 /data`  

---

- [X] Bluetooth. Kunna ansluta saker och ting.  
`sudo pacman -S bluez bluez-utils`  
`lsmod | grep btusb` (lsmod visar modulers status)
`sudo systemctl start bluetooth.service`  
`sudo systemctl enable bluetooth.service`  
`sudo pacman -S blueman` för GUI.  
Start `Bluetooth Manager` through wofi.  

---  

- [X] Sound.
`pactl info | grep "Server Name"` ger output:    
`Server Name: PulseAudio (on PipeWire 1.4.9)`  

sudo pacman -S  pipewire-audio 
                pipewire-pulse 
                pipewire-alsa 
                wireplumber 
                pipewire-jack 
                bluez 
                bluez-utils 
                bluez-plugins

systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user restart pipewire wireplumber

pactl list cards | grep -A2 "bluez_card"
pavucontrol  

pactl list cards | grep -A15 "bluez_card"  
pactl set-card-profile bluez_card.F4_4E_FC_87_DD_5D a2dp-sink  

- Check `systemctl status`  
There are three services running for sound. Understand this.  
`systemctl status | grep pipewire`  
`systemctl status | grep wireplumber`

---

- [X] Tailscale  
`sudo pacman -Syyu` - Uppdatera paketlistan  
`sudo pacman -S tailscale` - installera tailscale  

`sudo systemctl enable --now tailscaled` - sätt igång bakgrundsprocessen vid boot  
`sudo tailscale up` - Anslut din maskin till tailscale nätverket och autentisera i din webbläsare  
`tailscale ip -4` - Hitta din tailscale ip

---

- [X] SSH 
https://wiki.archlinux.org/title/OpenSSH              - LÄGG TILL HARDENING  
`sudo pacman -S openssh`  
`systemctl status sshd` - kolla om tjänsten körs  
`sudo systemctl enable --now sshd` - starta tjänsten nu och vid boot  

Paketet behöver installeras och köras på båda maskiner för att det ska fungera.   

---

- [X] Screenshot:
- grim (for screenshot)  
- slurp (for deciding pic borders)  
- swappy (for editing pic)  

- Installera paketen
`sudo pacman -S grim slurp swappy wev`  

- Skapa mappen:  
`mkdir -p ~/.local/bin`  

- Skapa filen:  
`nano ~/.local/bin/screenshot`  

- Med följande innehåll:  
#!/bin/bash
grim -g "$(slurp)" - | swappy -f -  

- Gör den körbar:  
`chmod +x ~/.local/bin/screenshot`  

- Skapa config filen:  
`touch ~/.config/swappy/config`  

- Med följande innehåll:  
[Default]
save_dir=$HOME/Pictures/Screenshots/  
save_filename_format=swappy-%Y%m%d-%H:%M:%S.png  

Fler parametrar kan sättas. Se repo för exempel:  
https://github.com/jtheoof/swappy/blob/master/README.md  




set that key to execute the script in hyprland.  
`bind = , 107, exec, ~/.local/bin/screenshot`   - Kan ändra "107" till "Print"  

**IF It does not work to bind with "Print", bind the print keycode**  
To bind correct keycode to printcreen button. Use `wev`:    
Press the button. Take note of keycode for print screen when you press it  

Example bind found on reddit:  
bind =, Print, exec, grim -g "$(slurp)" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify "Screenshot of the region taken" -t 1000 # screenshot of a region 


- [X] Firewall - ufw
`sudo pacman -S ufw`  
`sudo systemctl enable --now ufw`  

Min konfiguration:  
sudo ufw reset  
sudo ufw default deny incoming  
sudo ufw default allow outgoing  
sudo ufw enable  
udo ufw status verbose  

SSH fungerar med tailscale utan att explicit öppna porten. 

---

- [X] yay and pacseek  
`git clone https://aur.archlinux.org/yay.git`  
`cd yay`  
`makepkg -si`  

`yay -S pacseek`  # CLI based pacman manager




