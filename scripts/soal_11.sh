# ==========================================================
# == Script Gabungan Benchmarking & Optimasi Load Balancer ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. Benchmarking jika di 'Gilgalad' atau 'Amandil'    ==
# == 2. Update 'weight' Nginx jika di 'Elros'             ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE CLIENT (GILGALAD / AMANDIL) ===
    # =================================================
    "Gilgalad" | "Amandil")
        echo "--- Menjalankan script Benchmarking di $CURRENT_HOST ---"

        # 1. Cek service (jika node ini juga worker)
        echo "Memeriksa status service..."
        service nginx status || service nginx restart
        service php8.4-fpm status || service php8.4-fpm restart

        # 2. Install apache2-utils untuk 'ab'
        echo "Menginstall apache2-utils (untuk 'ab')..."
        apt update -y
        apt install -y apache2-utils

        # 3. Menjalankan Tes
        echo ""
        echo "--- Tes Konektivitas Dasar (curl) ---"
        curl -I http://elros.k16.com/api/airing
        echo ""

        echo "--- Low Load Test (100 Requests, 10 Concurrent) ---"
        ab -n 100 -c 10 http://elros.k16.com/api/airing/
        echo ""

        echo "--- Stress Test (2000 Requests, 100 Concurrent) ---"
        ab -n 2000 -c 100 http://elros.k16.com/api/airing/
        echo ""

        echo "--- Tes di $CURRENT_HOST Selesai ---"
        echo "Jika ini tes awal, jalankan script ini di Elros, lalu jalankan lagi di sini."
        ;;

    # =================================================
    # === KASUS 2: NODE REVERSE PROXY (ELROS)       ===
    # =================================================
    "Elros")
        echo "--- Meng-update Konfigurasi 'weight' di Elros ---"

        # 1. Menimpa konfigurasi Nginx dengan 'weight'
cat << 'EOF' > /etc/nginx/sites-available/reverse-proxy
# ============================
# Reverse Proxy - Elros (Weighted)
# ============================

upstream kesatria_numenor {
    # Bobot diatur: Elendil (3), Anarion (2), Isildur (1)
    server 192.219.1.2:8001 weight=3;    # Elendil — lebih kuat
    server 192.219.1.3:8002 weight=1;    # Isildur
    server 192.219.1.4:8003 weight=2;    # Anarion
}

server {
    listen 80;
    server_name elros.k16.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/elros-access.log;
    error_log  /var/log/nginx/elros-error.log;
}
EOF

        # 2. Aktivasi Konfigurasi
        echo "Mengecek sintaks Nginx..."
        nginx -t

        # 'reload' lebih baik dari 'restart' karena tidak ada downtime
        echo "Menerapkan konfigurasi baru (Nginx reload)..."
        service nginx reload

        echo "--- Konfigurasi 'weight' di Elros Selesai ---"
        echo "Sekarang, jalankan lagi script benchmark di Gilgalad/Amandil."
        echo ""
        echo "--- Cek Log di Elros untuk melihat distribusi beban: ---"
        echo "tail -f /var/log/nginx/elros-access.log"
        ;;

    # =================================================
    # === KASUS 3: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali dalam script ini."
        echo "Script ini hanya untuk node: Gilgalad, Amandil, atau Elros."
        exit 1
        ;;
esac