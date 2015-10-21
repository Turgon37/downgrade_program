# List of program to downgrade
# one or more program per line (space separated)
# A line which start by # is considered as a comment


DOWNGRADE_USER_root="
apt apt-cdrom apt-extracttemplates apt-get apt-mark apt-cache apt-config
apt-ftparchive apt-key apt-sortpkgs
dmidecode
dpkg dpkg-deb dpkg-divert dpkg-maintscript-helper dpkg-preconfigure dpkg-query
dpkg-reconfigure dpkg-split dpkg-statoverride dpkg-trigger
efibootmgr
grub-editenv grub-glue-efi grub-mkfont grub-mknetdir grub-mkrescue
grub-render-label grub-file grub-kbdcomp grub-mkimage update-grub
grub-mkpasswd-pbkdf2 grub-mkstandalone grub-script-check grub-fstest
grub-menulst2cfg grub-mklayout grub-mkrelpath grub-mount grub-syslinux2cfg
hdparm
sensors-detect
smartd

chcpu
fdisk cfdisk sfdisk
"


DOWNGRADE_GRP_admin="
# USER
last lastb lastlog faillog

# HARDWARE TOOLS
acpi acpi_listen
sensors
smartctl

# MEMORY TOOLS
free
vmstat

# CPU
uptime

# DISK
df
blkid lsblk

# CLOCK
hwclock
ntpdc ntpq ntpsweep ntptime ntptrace
timedatectl

# KERNEL/PROCESS INFORMATION TOOLS
arch
lscpu lshw lsusb lspci
lsmod lsinitramfs
lslocks lsof 
top ps
wdctl

# NETSTAT
netstat
ifconfig ip
ip6tables ip6tables-apply ip6tables-save ip6tables-restore
iptables iptables-apply iptables-save iptables-restore iptables-xml
iptables-loader
iptunnel ipcrm ipcs
ipmaddr ipcmk
ctstat lnstat ss

ethtool
ping ping6 traceroute

# VM STAT
docker
machinectl
qemu-img qemu-io qemu-make-debian-root qemu-nbd qemu-system-i386 qemu-system-x86_64
virsh virt-convert virt-host-validate virt-install virt-login-shell
virt-sanlock-cleanup virt-xml-validate virt-clone virtfs-proxy-helper
virt-image virtlockd virt-pki-validate virt-xml 
"
