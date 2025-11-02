# Script ini mengkonfigurasi Elendil, Isildur, dan Anarion
# sebagai web server (Nginx + PHP 8.4).

# --- 1. Instalasi Dependensi ---
# Update package list dan install Nginx, PHP (serta ekstensinya), dan Composer.
apt update -y
apt install -y nginx php8.4 php8.4-fpm php8.4-cli php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip unzip composer

# --- 2. Setup Direktori Web ---
# Membuat direktori root untuk project
mkdir -p /var/www/laravel
cd /var/www/laravel

# Membuat file PHP sederhana untuk testing (phpinfo)
echo "<?php phpinfo(); ?>" > index.php

# Kembali ke home directory
cd /
cd ~

# --- 3. Konfigurasi Nginx ---
# Menghapus symlink konfigurasi default Nginx
rm -f /etc/nginx/sites-enabled/default

# Membuat file konfigurasi Nginx baru untuk 'laravel'
# Menggunakan 'Here Document' untuk menulis isi file
cat << 'EOF' > /etc/nginx/sites-available/laravel
server {
    listen 80;
    server_name _;

    root /var/www/laravel;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # Mengarahkan Nginx ke socket PHP-FPM
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Blokir akses ke file .htaccess
    location ~ /\.ht {
        deny all;
    }
}
EOF

# --- 4. Aktivasi Konfigurasi dan Restart Service ---
    
# Tes sintaks konfigurasi Nginx
nginx -t

# Membuat symlink untuk mengaktifkan site 'laravel'
# -s (symbolic), -f (force/timpa jika sudah ada)
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Memulai dan me-restart service
# (Restart diperlukan untuk memastikan config baru ter-load)
service php8.4-fpm start
service nginx start
service php8.4-fpm restart
service nginx restart

# --- 5. Verifikasi Lokal ---
# Cek apakah Nginx (port 80) sedang listening
netstat -tuln | grep :80