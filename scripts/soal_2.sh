# ==========================================================
# == Script Gabungan Setup DHCP (Server, Relay, Client)   ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. 'Aldarion': Setup isc-dhcp-server                 ==
# == 2. 'Durin': Setup isc-dhcp-relay                     ==
# == 3. 'Gilgalad', 'Amandil', 'Khamul': Setup DHCP Client==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)

echo "--- Menjalankan script setup DHCP di $CURRENT_HOST ---"

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE DHCP SERVER (ALDARION)      ===
    # =================================================
    "Aldarion")
        echo "Node: Aldarion (DHCP Server)"
        
        # 1. Install server
        apt-get update && apt-get install -y isc-dhcp-server

        # 2. Konfigurasi interface (hanya listen di eth0 IPv4)
        echo "Mengkonfigurasi /etc/default/isc-dhcp-server..."
        echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server
        echo 'INTERFACESv6=""' >> /etc/default/isc-dhcp-server

        # 3. Buat file konfigurasi dhcpd.conf
        echo "Membuat /etc/dhcp/dhcpd.conf..."
        # 'EOF' dibungkus petik agar $ tidak diekspansi shell
        cat << 'EOF' > /etc/dhcp/dhcpd.conf
# Manusia
subnet 192.219.1.0 netmask 255.255.255.0 {
    range 192.219.1.6 192.219.1.34;
    range 192.219.1.68 192.219.1.94;
    option routers 192.219.1.1;
    option broadcast-address 192.219.1.255;
    option domain-name-servers 192.219.3.3;
    default-lease-time 1800;  # 30 menit
    max-lease-time 3600;      # 1 jam
}

# Peri
subnet 192.219.2.0 netmask 255.255.255.0 {
    range 192.219.2.35 192.219.2.67;
    range 192.219.2.96 192.219.2.121;
    option routers 192.219.2.1;
    option broadcast-address 192.219.2.255;
    option domain-name-servers 192.219.3.3;
    default-lease-time 600;   # 10 menit (1/6 jam)
    max-lease-time 3600;      # 1 jam
}

# Fixed Address (Subnet 3)
subnet 192.219.3.0 netmask 255.255.255.0 {
    option routers 192.219.3.1;
    option broadcast-address 192.219.3.255;
    option domain-name-servers 192.219.3.3;
}

# Subnet 4 (Aldarion's network)
subnet 192.219.4.0 netmask 255.255.255.0 {
    option routers 192.219.4.1;
    option broadcast-address 192.219.4.255;
    option domain-name-servers 192.219.3.3;
}

# Host Khamul dengan Fixed Address
host Khamul {
    hardware ethernet 02:42:dc:08:82:00;
    fixed-address 192.219.3.95;
}
EOF

        # 4. Restart service
        echo "Me-restart isc-dhcp-server..."
        service isc-dhcp-server restart
        
        echo "--- Setup Aldarion Selesai ---"
        echo "Verifikasi:"
        echo "service isc-dhcp-server status"
        echo "cat /var/lib/dhcp/dhcpd.leases"
        ;;

    # =================================================
    # === KASUS 2: NODE DHCP RELAY (DURIN)          ===
    # =================================================
    "Durin")
        echo "Node: Durin (DHCP Relay)"
        
        # 1. Install relay
        apt-get update && apt-get install -y isc-dhcp-relay

        # 2. Konfigurasi relay
        echo "Mengkonfigurasi /etc/default/isc-dhcp-relay..."
        # SERVERS = Alamat DHCP Server (Aldarion)
        echo 'SERVERS="192.219.4.2"' > /etc/default/isc-dhcp-relay
        # INTERFACES = Interface mana saja yg di-relay
        echo 'INTERFACES="eth1 eth2 eth3 eth4"' >> /etc/default/isc-dhcp-relay
        echo 'OPTIONS=""' >> /etc/default/isc-dhcp-relay

        # 3. Aktifkan IP Forwarding (Wajib untuk relay/router)
        echo "Mengaktifkan IP Forwarding..."
        echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
        sysctl -p

        # 4. Restart service
        echo "Me-restart isc-dhcp-relay..."
        service isc-dhcp-relay restart

        echo "--- Setup Durin Selesai ---"
        echo "Verifikasi:"
        echo "service isc-dhcp-relay status"
        echo "cat /proc/sys/net/ipv4/ip_forward (harus '1')"
        ;;

    # =================================================
    # === KASUS 3: NODE DHCP CLIENT (GILGALAD, DLL) ===
    # =================================================
    "Gilgalad" | "Amandil" | "Khamul")
        echo "Node: $CURRENT_HOST (DHCP Client)"

        # 1. Install client
        apt-get update
        apt-get install -y isc-dhcp-client

        # 2. Hapus konfigurasi IP lama
        echo "Menghapus konfigurasi IP lama di eth0..."
        ip addr flush dev eth0
        ip route del default
        
        # 3. Minta IP baru
        echo "Meminta IP baru dari DHCP server via relay..."
        dhclient -v eth0

        # 4. Verifikasi
        echo "--- Hasil Konfigurasi $CURRENT_HOST ---"
        echo "IP Address:"
        ip addr show eth0
        echo "MAC Address:"
        ip link show eth0 | grep ether
        
        if [ "$CURRENT_HOST" = "Khamul" ]; then
            echo "-> (Cek: IP harus 192.219.3.95)"
        fi
        ;;

    # =================================================
    # === KASUS 4: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali."
        echo "Script ini hanya untuk: Aldarion, Durin, Gilgalad, Amandil, atau Khamul."
        exit 1
        ;;
esac

echo "--- Script Selesai ---"