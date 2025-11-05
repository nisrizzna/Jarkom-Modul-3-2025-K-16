# ==========================================================
# == Script Gabungan Setup Nginx Caching (Pharazon/Clients) ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. 'Pharazon': Setup Nginx proxy_cache.              ==
# == 2. 'Gilgalad'/'Amandil': Menjalankan tes 'curl'.     ==
# == 3. 'Galadriel': Memberi instruksi verifikasi log.    ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE LOAD BALANCER (PHARAZON)    ===
    # =================================================
    "Pharazon")
        echo "--- Menjalankan setup Nginx Proxy Caching di Pharazon ---"

        # 1. Buat direktori cache dan atur izin
        echo "Membuat direktori cache di /var/cache/nginx/proxy_cache..."
        mkdir -p /var/cache/nginx/proxy_cache
        chown -R www-data:www-data /var/cache/nginx/proxy_cache

        # 2. Tentukan file konfigurasi
        CONFIG_FILE="/etc/nginx/sites-available/pharazon-lb"

        # 3. Definisikan path cache
        # levels=1:2 = struktur direktori cache
        # keys_zone=my_cache:100m = Nama zona 'my_cache', 100MB di memori
        # max_size=500m = Maks ukuran cache di disk
        # inactive=10m = Hapus cache jika 10m tidak diakses
        CACHE_PATH_DEF="proxy_cache_path /var/cache/nginx/proxy_cache levels=1:2 keys_zone=my_cache:100m max_size=500m inactive=10m use_temp_path=off;"

        # 4. Tambahkan 'proxy_cache_path' (sebelum 'limit_req_zone' atau 'server')
        # (Hanya jika belum ada)
        if ! grep -q "proxy_cache_path" "$CONFIG_FILE"; then
            echo "Menambahkan proxy_cache_path..."
            # 'i\' = insert before baris yang match
            sed -i "/limit_req_zone/i $CACHE_PATH_DEF\n" "$CONFIG_FILE"
        else
            echo "proxy_cache_path sudah ada."
        fi

        # 5. Tambahkan 'proxy_cache' di dalam 'location /'
        # (Hanya jika belum ada)
        if ! grep -q "proxy_cache my_cache;" "$CONFIG_FILE"; then
            echo "Menambahkan konfigurasi proxy_cache di location..."
            # 'a\' = append (tambahkan) setelah baris yang match
            # '$' pada '$upstream_cache_status' perlu di-escape (\$)
            # '$host' juga di-escape (\$)
            sed -i "/proxy_set_header Host \$host;/a \ \n        # --- CACHING ENABLED --- \n        proxy_cache my_cache;\n        proxy_cache_valid 200 302 10m;\n        proxy_cache_valid 404 1m;\n        add_header X-Cache-Status \$upstream_cache_status;\n        proxy_cache_methods GET HEAD;" "$CONFIG_FILE"
        else
            echo "proxy_cache sudah ada."
        fi

        # 6. Reload Nginx
        echo "Mengecek sintaks dan me-reload Nginx..."
        nginx -t
        service nginx reload

        echo "--- Caching di Pharazon diaktifkan ---"
        echo "Jalankan script ini di Gilgalad/Amandil untuk tes."
        echo "Lalu cek isi cache di sini:"
        echo "ls -lh /var/cache/nginx/proxy_cache/"
        ;;

    # =================================================
    # === KASUS 2: NODE CLIENT (GILGALAD / AMANDIL) ===
    # =================================================
    "Gilgalad" | "Amandil")
        echo "--- Menjalankan Tes Verifikasi Cache dari $CURRENT_HOST ---"
        
        URL="http://pharazon.k16.com/"

        echo "--- Tes 1: Cek X-Cache-Status (Harusnya MISS) ---"
        # -I = Hanya ambil headers
        # -u = User:Password
        curl -I -u noldor:silvan $URL
        
        echo ""
        echo "Menunggu 2 detik..."
        sleep 2
        echo ""

        echo "--- Tes 2: Cek X-Cache-Status (Harusnya HIT) ---"
        curl -I -u noldor:silvan $URL

        echo "--- Verifikasi Selesai ---"
        echo "Cek X-Cache-Status di atas. Tes 1 harus 'MISS', Tes 2 harus 'HIT'."
        ;;

    # =================================================
    # === KASUS 3: NODE WORKER (GALADRIEL, DLL)     ===
    # =================================================
    "Galadriel" | "Celeborn" | "Oropher")
        echo "Node ini adalah $CURRENT_HOST (worker)."
        echo "Untuk memverifikasi caching dari sisi worker:"
        echo ""
        echo "Jalankan perintah ini:"
        echo "tail -f /var/log/nginx/access.log"
        echo ""
        echo "Anda seharusnya hanya melihat request PERTAMA dari Pharazon."
        echo "Request berikutnya (selama 10 menit) TIDAK akan muncul di log ini"
        echo "karena sudah dilayani oleh cache Pharazon."
        ;;
        
    # =================================================
    # === KASUS 4: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali."
        echo "Script ini hanya untuk: Pharazon, Gilgalad, Amandil, atau node worker (Galadriel, dll)."
        exit 1
        ;;
esac