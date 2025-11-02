# Script ini menimpa file /etc/dhcp/dhcpd.conf dengan konfigurasi baru
# untuk praktikum jaringan komputer di Aldarion.

# Menggunakan 'Here Document' (cat << 'EOF' ... EOF)
# untuk menulis/menimpa isi file /etc/dhcp/dhcpd.conf
cat << 'EOF' > /etc/dhcp/dhcpd.conf
# DHCP Configuration - Aldarion (DHCP Server)

# --- Opsi Global ---
ddns-update-style none;
authoritative;          # Menandakan ini server DHCP resmi di jaringan
log-facility local7;

# Batas maksimum peminjaman untuk semua keluarga (1 jam)
# (Diganti dari 7200 menjadi 3600)
max-lease-time 3600;


# --- SUBNET 1 - MANUSIA ---
subnet 192.219.1.0 netmask 255.255.255.0 {
    # Range IP yang boleh disewakan ke client
    range 192.219.1.6 192.219.1.34;
    range 192.219.1.68 192.219.1.94;
    
    # Opsi jaringan yang akan diterima client
    option routers 192.219.1.1;                     # Gateway
    option broadcast-address 192.219.1.255;
    option domain-name-servers 192.219.3.2, 192.219.3.3, 192.168.122.1; # DNS

    # Waktu sewa IP default khusus untuk subnet Manusia: 30 menit
    default-lease-time 1800;
}

# --- SUBNET 2 - PERI ---
subnet 192.219.2.0 netmask 255.255.255.0 {
    # Range IP yang boleh disewakan ke client
    range 192.219.2.35 192.219.2.67;
    range 192.219.2.96 192.219.2.121;
    
    # Opsi jaringan yang akan diterima client
    option routers 192.219.2.1;
    option broadcast-address 192.219.2.255;
    option domain-name-servers 192.219.3.2, 192.219.3.3, 192.168.122.1;

    # Waktu sewa IP default khusus untuk subnet Peri: 10 menit
    default-lease-time 600;
}

# --- SUBNET 3 - KURCACI ---
# Subnet ini hanya didefinisikan, tapi tidak ada 'range'
# Artinya, tidak ada pembagian IP dinamis di sini
subnet 192.219.3.0 netmask 255.255.255.0 {
    option routers 192.219.3.1;
    option broadcast-address 192.219.3.255;
}

# --- SUBNET 4 - DATABASE ---
subnet 192.219.4.0 netmask 255.255.255.0 {
    option routers 192.219.4.1;
    option broadcast-address 192.219.4.255;
}

# --- SUBNET 5 - PROXY ---
subnet 192.219.5.0 netmask 255.255.255.0 {
    option routers 192.219.5.1;
    option broadcast-address 192.219.5.255;
}

# --- FIXED ADDRESS - KHAMUL ---
# Memberikan IP statis (reservasi) ke client 'Khamul'
# berdasarkan MAC Address-nya
host Khamul {
    hardware ethernet 02:42:d6:54:3a:00;
    fixed-address 192.219.3.95;
}
EOF

# Konfigurasi telah ditulis.
# Langkah terakhir adalah me-restart service DHCP agar perubahan diterapkan.
service isc-dhcp-server restart