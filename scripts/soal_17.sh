# ==========================================================
# == Script Simulasi & Kegagalan Load Balancer            ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. 'Gilgalad': Install 'ab' & jalankan benchmark.    ==
# == 2. 'Pharazon': Update format log Nginx & restart.    ==
# == 3. 'Galadriel': Stop Nginx (simulasi gagal).         ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE CLIENT (GILGALAD)           ===
    # =================================================
    "Gilgalad")
        echo "--- Menjalankan script Benchmark di Gilgalad ---"

        # 1. Install apache2-utils untuk 'ab' (Apache Benchmark)
        echo "Menginstall apache2-utils (untuk 'ab')..."
        apt update -y
        apt install -y apache2-utils

        # 2. Menjalankan Tes Benchmark
        # Script ini akan menjalankan 1x benchmark.
        # Jalankan script ini lagi setelah Pharazon di-update
        # dan setelah Galadriel di-stop untuk melihat hasilnya.
        echo ""
        echo "--- Menjalankan Benchmark (100 Request, 10 Concurrent) ---"
        
        # -H "..." = Menambahkan header Authorization Basic
        # $(echo -n ... | base64) = Membuat header auth secara dinamis
        ab -n 100 -c 10 -H "Authorization: Basic $(echo -n 'noldor:silvan' | base64)" http://pharazon.k16.com/
        
        echo ""
        echo "--- Tes di Gilgalad Selesai ---"
        ;;

    # =================================================
    # === KASUS 2: NODE LOAD BALANCER (PHARAZON)    ===
    # =================================================
    "Pharazon")
        echo "--- Meng-update format log Nginx di Pharazon ---"
        
        CONFIG_FILE="/etc/nginx/nginx.conf"
        
        # 1. Definisikan format log baru dengan $upstream_addr
        # Ini akan menimpa format 'combined' yang sudah ada
        LOG_FORMAT_LINE="    log_format combined '\$remote_addr - \$remote_user [\$time_local] ' \
                               '\"\$request\" \$status \$body_bytes_sent ' \
                               '\"\$http_referer\" \"\$http_user_agent\" ' \
                               '\$upstream_addr';"
        
        # 2