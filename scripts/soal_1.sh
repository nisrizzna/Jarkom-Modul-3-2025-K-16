# ==========================================================
# == Script Konfigurasi Jaringan (Network Interfaces)     ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menimpa           ==
# == /etc/network/interfaces dengan konfigurasi yg benar. ==
# ==========================================================

CURRENT_HOST=$(hostname)
CONFIG_FILE="/etc/network/interfaces"

echo "--- Mengkonfigurasi network di $CURRENT_HOST ---"

# Hapus konfigurasi lama (jika ada) dan mulai dengan 'auto lo'
cat << 'EOF' > $CONFIG_FILE
auto lo
iface lo inet loopback

EOF

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: ROUTER (DURIN)                   ===
    # =================================================
    "Durin")
        echo "Node: Durin (Router)"
        # Menambahkan konfigurasi ke /etc/network/interfaces
        cat << 'EOF' >> $CONFIG_FILE
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
EOF
        
        echo "Mengaktifkan IP Forwarding dan MASQUERADE (NAT)..."
        # Aktifkan IP forwarding (Penting untuk NAT)
        sysctl -w net.ipv4.ip_forward=1
        
        # Terapkan aturan iptables
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.219.0.0/16
        ;;

    # =================================================
    # === KASUS 2: CLIENTS DHCP (Amandil, Gilgalad) ===
    # =================================================
    "Amandil" | "Gilgalad")
        echo "Node: $CURRENT_HOST (DHCP Client)"
        cat << 'EOF' >> $CONFIG_FILE
auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;
        
    # =================================================
    # === KASUS 3: CLIENT DHCP (MAC Tetap)          ===
    # =================================================
    "Khamul")
        echo "Node: Khamul (DHCP Client w/ Fixed MAC)"
        cat << 'EOF' >> $CONFIG_FILE
auto eth0
iface eth0 inet dhcp
    hwaddress ether 02:42:dc:08:82:00
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;

    # =================================================
    # === KASUS 4: NODES STATIS (Grouping by Gateway) ==
    # =================================================

    # --- Group Gateway 192.219.1.1 ---
    "Elendil" | "Isildur" | "Anarion" | "Miriel" | "Elros")
        echo "Node: $CURRENT_HOST (Gateway 192.219.1.1)"
        IP_ADDR=""
        case $CURRENT_HOST in
            "Elendil") IP_ADDR="192.219.1.2" ;;
            "Isildur") IP_ADDR="192.219.1.3" ;;
            "Anarion") IP_ADDR="192.219.1.4" ;;
            "Miriel") IP_ADDR="192.219.1.5" ;;
            "Elros") IP_ADDR="192.219.1.7" ;;
        esac
        
        # 'EOF' tanpa kutip agar $IP_ADDR terbaca
        cat << EOF >> $CONFIG_FILE
auto eth0
iface eth0 inet static
    address $IP_ADDR
    netmask 255.255.255.0
    gateway 192.219.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;

    # --- Group Gateway 192.219.2.1 ---
    "Celebrimbor" | "Pharazon" | "Galadriel" | "Celeborn" | "Oropher")
        echo "Node: $CURRENT_HOST (Gateway 192.219.2.1)"
        IP_ADDR=""
        case $CURRENT_HOST in
            "Celebrimbor") IP_ADDR="192.219.2.3" ;;
            "Pharazon") IP_ADDR="192.219.2.4" ;;
            "Galadriel") IP_ADDR="192.219.2.5" ;;
            "Celeborn") IP_ADDR="192.219.2.6" ;;
            "Oropher") IP_ADDR="192.219.2.7" ;;
        esac

        cat << EOF >> $CONFIG_FILE
auto eth0
iface eth0 inet static
    address $IP_ADDR
    netmask 255.255.255.0
    gateway 192.219.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;
        
    # --- Group Gateway 192.219.3.1 ---
    "Erendis" | "Amdir")
        echo "Node: $CURRENT_HOST (Gateway 192.219.3.1)"
        IP_ADDR=""
        case $CURRENT_HOST in
            "Erendis") IP_ADDR="192.219.3.3" ;;
            "Amdir") IP_ADDR="192.219.3.4" ;;
        esac

        cat << EOF >> $CONFIG_FILE
auto eth0
iface eth0 inet static
    address $IP_ADDR
    netmask 255.255.255.0
    gateway 192.219.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;

    # --- Group Gateway 192.219.4.1 ---
    "Aldarion" | "Palantir" | "Narvi")
        echo "Node: $CURRENT_HOST (Gateway 192.219.4.1)"
        IP_ADDR=""
        case $CURRENT_HOST in
            "Aldarion") IP_ADDR="192.219.4.2" ;;
            "Palantir") IP_ADDR="192.219.4.3" ;;
            "Narvi") IP_ADDR="192.219.4.4" ;;
        esac

        cat << EOF >> $CONFIG_FILE
auto eth0
iface eth0 inet static
    address $IP_ADDR
    netmask 255.255.255.0
    gateway 192.219.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;

    # --- Group Gateway 192.219.5.1 ---
    "Minastir")
        echo "Node: Minastir (Gateway 192.219.5.1)"
        cat << 'EOF' >> $CONFIG_FILE
auto eth0
iface eth0 inet static
    address 192.219.5.2
    netmask 255.255.255.0
    gateway 192.219.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF
        ;;
        
    # =================================================
    # === KASUS 5: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali."
        echo "Tidak ada konfigurasi network yang diterapkan."
        exit 1
        ;;
esac

echo "Konfigurasi network di $CONFIG_FILE telah ditulis."
echo "Menerapkan perubahan network (service networking restart)..."

# Restart service untuk menerapkan
service networking restart

echo "--- Konfigurasi Selesai ---"
echo ""

# --- Langkah Verifikasi Akhir ---
echo "Memastikan /etc/resolv.conf..."
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "Tes ping ke google.com..."
ping -c 3 google.com