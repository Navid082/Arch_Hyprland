# Setting up the new environment
This document does not contain any config files. It shows only how I went about setting setting everything up.


## Setup ##
Packages installed together with hyprland (See HostArchDocs):
- [X] alacritty
- [X] tldr
- [X] tree
- [X] dysk
- [X] btop
- [X] curl
- [~] dunst - ej konfigurerat.

waybar and wofi are configured below. Config files are not explored here.
Dunst is installed but not configured.


Packages installed later
- [X] man-db
- [X] discord
- [X] spotify
- [X] pavucontrol
- [X] 7zip
- [X] eye of gog
- [X] vim
- [X] docker
- [X] git
- [X] eza - satte detta som alias i bashrc
- [X] bat - nicer cat
- [X] kvm/qemu + virt-manager - Ska jag dokumentera detta här eller i egen fil?
- [X] pipewire pipewire-pulse pipewire-alsa wireplumber
- [X] thunar - set to dark mode in hyprland.conf https://wiki.archlinux.org/title/GTK
- [ ] thunderbird for emails.


Other
- [X] Keybinding. Break out your bindings to a seperate file.
- [X] Grub. changed to menu style hidden and timeout to 0 for faster boot process.


Todo:
- [ ] wl-clipboard - Går redan klippa och klistra. Behövs detta? 
- [ ] SWAP (move to archinstallation doc after implementing?)
- [ ] Power menu
- [ ] Screenshot: grim (for screenshot) - slurp (for deciding pic borders) - swappy (for editing pic)
- [ ] Skärmdelning
- [ ] USB ska kunna gå att läsa
- [ ] rsync
- [ ] ssh
- [ ] tailscale?
- [ ] wireshark?
- [ ] packettracer?
- [ ] docker


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
`logout ="hyprctl dispatch exit"`

--- 

- [x] waybar  (statusbar)

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

- [x] swaybg (wallpaper)
In **~/.config/hypr/autostart.conf** add the following:  
`exec-once = swaybg -c 000000` which will set background to black at login.  

For monitor specific wallpaper:  
List your monitors: `xrandr --listmonitors` : take note of monitor ID  
Mine is set to:  
`exec-once = swaybg -o DP-1 -i ~/Pictures/Wallpapers/mt3.jpg` # Main screen  
`exec-once = swaybg -o HDMI-A-1 -c 000000` # Secondary screen  

---

- [x] swaylock (lockscreen)  
Swaylock per default have a bright grey lockscreen.
I set mine to black with keybinding.  
Edit `**~/.config/hypr/hyprland** under **KEYBINDS** add the follwing:  

`bind = $mainMod, L, exec, swaylock -c 000000`

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

- [x] Steam (multilib)  
The game I mostly play is Heroes of Newerth. Though it does not have Linux support at all  
I decided to try to make it work with steams proton. Which it did.  
1. Install Steam.
2. Added the installer through `add a non steam game` and installed the game.  
Had to try different proton versions to finally make it work. `Proton Experimental` did the trick.  
3. Since installer is still set as the target executable. I changed it to `launcher.exe` by right-clicking on the game in the library and finding where the `launcher.exe` is installed.  
The right directory was found here:  
`~/.steam/steam/steamapps/compdata/<app-id>/pfx/drive_c/ProgramFiles/Heroes of Newerth/`  
4. Had som issues but by adding `PROTON_USE_WINED3D=1 %command%` to launch options it was finally done.

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
pavucontrol.

  496  pactl list cards | grep -A15 "bluez_card"
  497  pactl set-card-profile bluez_card.F4_4E_FC_87_DD_5D a2dp-sink


# Check `systemctl status`  
There are three services running for sound. Understand this.  
`systemctl status | grep pipewire`  
`systemctl status | grep wireplumber`
