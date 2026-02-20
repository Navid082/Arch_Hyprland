Based on:
https://gist.github.com/tatumroaquin/c6464e1ccaef40fd098a4f31db61ab22

This document describes the virtualization configuration on this Arch Linux system.

## 1. Check Virtualization Support  
`lscpu | grep -i Virtualization`  

---  

## 2. Ensure that your kernel includes KVM modules  
`zgrep CONFIG_KVM /proc/config.gz`  

---

## 3. Install QEMU, libvirt, viewers, and tools  
`sudo pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf dnsmasq libosinfo`  

---

## 4. Enable the monolithic daemon.  
### Option 1  
`sudo systemctl enable libvirtd.service`  
This ensures the libvirt daemon starts at boot.  
If the service is not currently running, start it manually:   
`systemctl start libvirtd`  

### Option 2  
Use socket activation (recommended)  
`sudo systemctl enable --now libvirtd.socket`  
With socket activation enabled, the daemon starts automatically when a client (e.g. virt-manager or virsh) connects.

---

## 5. Verify Host Virtualization and ensure NAT network is active  
`sudo virt-host-validate qemu`  
`sudo virsh net-start default`  
`sudo virsh net-autostart default`  

---

## 6. Libvirt has two methods for connecting to the KVM Hypervisor. Session and System.  
For my setup I'll go with System.  

### 6.1. Check current mode  
`sudo virsh uri`  

### 6.2 Add the current user to the libvirt group  
`sudo usermod -aG libvirt $USER`  

### 6.3. Set env variable with the default uri and check  
`echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc`  
`sudo virsh uri`  

--- 

## 7. Set ACL for the KVM images directory  
### 7.1. Check permissions on the images directory  
`sudo getfacl /var/lib/libvirt/images`  

### 7.2. Recursively remove existing ACL permissions  
`sudo setfacl -R -b /var/lib/libvirt/images/`  

### 7.3. Rrecursively grant permission to the current user  
`sudo setfacl -R -m "u:${USER}:rwX" /var/lib/libvirt/images/`  

### 7.4. Enable special permissions default ACL  
`sudo setfacl -m "d:u:${USER}:rwx" /var/lib/libvirt/images/`  

### 7.5. Verify your ACL permissions within the images directory.  
`sudo getfacl /var/lib/libvirt/images/`  