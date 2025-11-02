# ==========================================================
# == Script Gabungan Setup Rate Limiting (Load Balancers) ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. 'Elros'/'Pharazon': Terapkan Nginx rate limiting. ==
# == 2. 'Gilgalad'/'Amandil': Install 'ab' & stress test. ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE LOAD BALANCER (ELROS / PHARAZON) ==
    # =================================================
    "Elros" | "Pharazon")
        echo "--- Menerapkan Rate Limiting di $CURRENT_HOST ---"

        # Tentukan file konfigurasi berdasarkan nama host
        if [ "$CURRENT_HOST" = "Elros" ]; then
            # Menggunakan file 'reverse-proxy' dari script sebelumnya
            # (Jika kamu ganti nama file, sesuaikan di sini)
            CONFIG_FILE="/etc/nginx/sites-available/reverse-proxy" 
        else
            CONFIG_FILE="/etc/nginx/sites-available/pharazon-lb"
        fi

        # 1. Definisikan zona rate limiting
        # $binary_remote_addr = IP client
        # zone=one:10m = Nama zona 'one', ukuran 10MB
        # rate=10r/s = Izinkan 10 request per detik
        ZONE_DEF="limit_req_zone \$binary_remote_addr zone=one:10m rate=10r/s;"

        # 2. Definisikan aturan limit di dalam 'location'
        # burst=20 = Izinkan 'ledakan' 20 request di atas rate
        # nodelay = Langsung layani request (jangan ditunda)
        LIMIT_REQ_LINE="    limit_req zone=one burst=20 nodelay;"

        # 3. Tambahkan 'limit_req_zone' di baris pertama file
        # (Hanya jika belum ada)
        if ! grep -q "limit_req_zone" "$CONFIG_FILE"; then
            echo "Menambahkan 'limit_req_zone'..."
            # '1i' = insert di baris 1
            sed -i "1i$ZONE_DEF" "$CONFIG_FILE"
        else
            echo "'limit_req_zone' sudah ada."
        fi

        # 4. Tambahkan 'limit_req' di dalam 'location /'
        # (Hanya jika belum ada)
        if ! grep -q "limit_req zone=one" "$CONFIG_FILE"; then
            echo "Menambahkan 'limit_req'..."
            # '/location \/ {/a' = append (tambahkan) setelah 'location / {'
            sed -i "/location \/ {/a \\$LIMIT_REQ_LINE" "$CONFIG_FILE"
        else
            echo "'limit_req' sudah ada."
        fi

        # 5. Reload Nginx
        echo "Mengecek sintaks dan me-reload Nginx..."
        nginx -t
        service nginx reload

        echo "--- Rate limiting di $CURRENT_HOST diaktifkan ---"
        echo "Jalankan script ini di Gilgalad/Amandil untuk tes."
        echo "Lalu cek log error di sini:"
        echo "tail -f /var/log/nginx/error.log"
        ;;

    # =================================================
    # === KASUS 2: NODE CLIENT (GILGALAD / AMANDIL) ===
    # =================================================
    "Gilgalad" | "Amandil")
        echo "--- Menjalankan Stress Test dari $CURRENT_HOST ---"

        # 1. Install apache2-utils untuk 'ab'
        echo "Menginstall apache2-utils..."
        apt update -y
        apt install -y apache2-utils

        echo ""
        echo "--- Mengetes PHARAZON (500 req, 50 concurrent) ---"
        # Tes ini seharusnya memicu rate limit di Pharazon
        # -H '...' = Menambahkan header otorisasi
        ab -n 500 -c 50 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/
        
        echo ""
        echo "--- Mengetes ELROS (500 req, 50 concurrent) ---"
        # Tes ini seharusnya memicu rate limit di Elros
        ab -n 500 -c 50 http://elros.k32.com/
        echo ""

        echo "--- Stress test selesai. ---"
        echo "Cek /var/log/nginx/error.log di Pharazon dan Elros"
        echo "untuk melihat pesan 'limiting requests'."
        ;;

    # =================================================
    # === KASUS 3: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali."
        echo "Script ini hanya untuk node: Elros, Pharazon, Gilgalad, atau Amandil."
        exit 1
        ;;
esac