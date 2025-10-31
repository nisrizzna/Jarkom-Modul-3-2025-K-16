CONFIG

#  Durin
auto lo
iface lo inet loopback
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.219.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.219.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.219.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.219.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 192.219.5.1
    netmask 255.255.255.0

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.219.0.0/16

#  Elendil
auto eth0
iface eth0 inet static
    address 192.219.1.2
    netmask 255.255.255.0
    gateway 192.219.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Isildur
auto eth0
iface eth0 inet static
    address 192.219.1.3
    netmask 255.255.255.0
    gateway 192.219.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Anarion
auto eth0
iface eth0 inet static
    address 192.219.1.4
    netmask 255.255.255.0
    gateway 192.219.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Miriel
auto eth0
iface eth0 inet static
    address 192.219.1.5
    netmask 255.255.255.0
    gateway 192.219.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Amandil
auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Elros
auto eth0
iface eth0 inet static
    address 192.219.1.7
    netmask 255.255.255.0
    gateway 192.219.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Gilgalad
auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Celebrimbor
auto eth0
iface eth0 inet static
    address 192.219.2.3
    netmask 255.255.255.0
    gateway 192.219.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Pharazon
auto eth0
iface eth0 inet static
    address 192.219.2.4
    netmask 255.255.255.0
    gateway 192.219.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Galadriel
auto eth0
iface eth0 inet static
    address 192.219.2.5
    netmask 255.255.255.0
    gateway 192.219.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Celeborn
auto eth0
iface eth0 inet static
    address 192.219.2.6
    netmask 255.255.255.0
    gateway 192.219.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Oropher
auto eth0
iface eth0 inet static
    address 192.219.2.7
    netmask 255.255.255.0
    gateway 192.219.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Khamul (Client-Fixed-Address)
auto eth0
iface eth0 inet dhcp
    hwaddress ether 02:42:dc:08:82:00
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Erendis
auto eth0
iface eth0 inet static
    address 192.219.3.3
    netmask 255.255.255.0
    gateway 192.219.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Amdir
auto eth0
iface eth0 inet static
    address 192.219.3.4
    netmask 255.255.255.0
    gateway 192.219.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Aldarion
auto eth0
iface eth0 inet static
    address 192.219.4.2
    netmask 255.255.255.0
    gateway 192.219.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Palantir
auto eth0
iface eth0 inet static
    address 192.219.4.3
    netmask 255.255.255.0
    gateway 192.219.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Narvi
auto eth0
iface eth0 inet static
    address 192.219.4.4
    netmask 255.255.255.0
    gateway 192.219.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

#  Minastir
auto eth0
iface eth0 inet static
    address 192.219.5.2
    netmask 255.255.255.0
    gateway 192.219.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf


# Mengecek koneksi
echo "nameserver 192.168.122.1" > /etc/resolv.conf
ping google.com