## findings - info - whatever ##

killall [namn]			- dödar program/processer?  
pk -9 [namn]			- dödar program/processer?  
journalctl				- loggar  
systemd?				- bakgrundsprocesser?  
nohup <name> >/dev/null 2>&1 &	- Allows program to live when terminal closes
daemon?
pactl info?
dd 	                    - command that allows creation of bootable usb-drive/clone drive/benchmark a disk etc. 

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_personal

pacman -Qe <namn>		- visa manuellt installerade paket.  
pacman -Qi <namn>		- visa info om angivet paket  
pacman -Qtd             - List orphan packages


suspend 				- viloläge	- satt alias i bashrc  
logout 					- loggar ut (allting stängs av) - satt alias i bashrc  
sudo reboot now 		- startar om  
sudo shutdown now 		- stänger av 
