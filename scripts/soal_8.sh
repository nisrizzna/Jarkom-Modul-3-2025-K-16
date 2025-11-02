# ==========================================================
# == Script Gabungan Setup Praktikum Jarkom               ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. Setup Database Server jika di 'Palantir'          ==
# == 2. Setup Worker Node jika di 'Elendil', 'Isildur',   ==
# ==    atau 'Anarion'                                    ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE DATABASE (PALANTIR)         ===
    # =================================================
    "Palantir")
        echo "--- Menjalankan setup Database di Palantir ---"

        # 1. Instalasi MariaDB
        apt update -y
        apt install -y mariadb-server
        service mariadb start

        # 2. Konfigurasi Database & User via SQL
        mysql -u root <<EOF
CREATE DATABASE laravel_db;
CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravel123';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel'@'%';
FLUSH PRIVILEGES;
EXIT;
EOF

        # 3. Konfigurasi Remote Access (agar bisa diakses worker)
        # Mengubah bind-address dari 127.0.0.1 (localhost) ke 0.0.0.0 (semua IP)
        sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

        # 4. Restart service untuk menerapkan perubahan
        service mariadb restart
        
        echo "--- Setup Palantir Selesai ---"
        ;;

    # =================================================
    # === KASUS 2: NODE WORKER (ELENDIL, DLL.)      ===
    # =================================================
    "Elendil" | "Isildur" | "Anarion")
        echo "--- Menjalankan setup Worker di $CURRENT_HOST ---"

        # 1. Instalasi Dependensi (Nginx, PHP, Git, Composer)
        apt update -y
        apt install -y php8.4 php8.4-fpm php8.4-mysql composer nginx git unzip

        # 2. Setup Project Laravel
        rm -rf /var/www/laravel
        cd /var/www
        git clone https://github.com/laravel/laravel.git laravel
        cd laravel
        
        composer install
        cp .env.example .env
        php artisan key:generate

        # 3. Konfigurasi .env untuk konek ke Palantir
        sed -i "s/DB_HOST=127.0.0.1/DB_HOST=192.219.4.3/g" .env
        sed -i "s/DB_DATABASE=laravel/DB_DATABASE=laravel_db/g" .env
        sed -i "s/DB_USERNAME=root/DB_USERNAME=laravel/g" .env
        sed -i "s/DB_PASSWORD=/DB_PASSWORD=laravel123/g" .env

        # 4. Konfigurasi Nginx (Dinamis berdasarkan Hostname)
        # Menentukan Port berdasarkan nama host
        PORT="8000" # Port default jika ada host lain
        if [ "$CURRENT_HOST" = "Elendil" ]; then
            PORT="8001"
        elif [ "$CURRENT_HOST" = "Isildur" ]; then
            PORT="8002"
        elif [ "$CURRENT_HOST" = "Anarion" ]; then
            PORT="8003"
        fi
        
        SERVER_NAME="$CURRENT_HOST.k32.com"

        # Menulis file konfigurasi Nginx
        # Menggunakan EOF (tanpa kutip) agar $PORT dan $SERVER_NAME bisa masuk
        # Variabel Nginx ($uri, $query_string) di-escape dengan backslash (\)
        cat << EOF > /etc/nginx/sites-available/laravel
server {
    listen $PORT;
    server_name $SERVER_NAME;

    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

        # 5. Aktivasi Nginx & Restart Services
        # Menggunakan -sf (symbolic, force) untuk menimpa config lama (dari phpinfo)
        ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
        nginx -t
        service nginx restart
        service php8.4-fpm restart

        # 6. Migrasi Database (Hanya dijalankan di 1 node, kita pilih Elendil)
        if [ "$CURRENT_HOST" = "Elendil" ]; then
            echo "--- Menjalankan Migrasi & Seeder (hanya di Elendil) ---"
            cd /var/www/laravel
            
            # (Tambahan) Memberi izin folder storage/cache
            chown -R www-data:www-data storage bootstrap/cache
            chmod -R 775 storage bootstrap/cache

            # Menjalankan migrasi
            php artisan migrate:fresh --seed
        fi

        echo "--- Setup $CURRENT_HOST Selesai ---"
        ;;

    # =================================================
    # === KASUS 3: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali dalam script ini."
        echo "Script ini hanya untuk node: Palantir, Elendil, Isildur, atau Anarion."
        exit 1
        ;;
esac