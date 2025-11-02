# ==========================================================
# == Script Setup PHP Worker (Galadriel, Celeborn, Oropher) ==
# ==                                                      ==
# == Script ini mengkonfigurasi Nginx + PHP-FPM.          ==
# == Script ini dinamis: akan menggunakan hostname        ==
# == server (misal 'galadriel') untuk server_name.        ==
# == Juga memblokir akses via IP address.                 ==
# ==========================================================

# --- 1. Instalasi Dependensi ---
echo "Melakukan update dan instalasi Nginx + PHP..."
apt update -y
apt install -y nginx php8.4-fpm

# --- 2. Membuat File Web Sederhana ---
# File index.php ini akan menampilkan nama host server
echo '<?php echo "Welcome to Taman Digital "; echo gethostname(); ?>' > /var/www/html/index.php

# Memberikan izin folder web ke user Nginx
chown -R www-data:www-data /var/www/html

# --- 3. Konfigurasi Nginx ---
echo "Mengkonfigurasi Nginx..."

# Menghapus symlink default
rm -f /etc/nginx/sites-enabled/default

# Mengambil hostname saat ini (misal: galadriel)
CURRENT_HOST=$(hostname)

# Membuat file konfigurasi baru secara dinamis
# $CURRENT_HOST akan otomatis diisi dengan nama host server
cat << EOF > /etc/nginx/sites-available/php-worker
# Blok utama untuk melayani domain
server {
    listen 80;
    # Server_name diisi otomatis berdasarkan hostname server
    server_name $CURRENT_HOST.k32.com;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # Pastikan path socket ini benar untuk versi PHP Anda
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama"
server {
    listen 80 default_server;
    server_name _; # Menangkap semua host/IP yang tidak cocok di atas
    
    # Menutup koneksi tanpa respons (lebih 'stealth' daripada 403)
    return 444;
}
EOF

# --- 4. Aktivasi Konfigurasi & Restart ---
echo "Mengaktifkan site dan me-restart service..."

# Membuat symlink untuk mengaktifkan site
# -s (symbolic), -f (force/timpa jika sudah ada)
ln -sf /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/

# Tes sintaks konfigurasi Nginx
nginx -t

# Restart service agar perubahan diterapkan
service php8.4-fpm restart
service nginx restart

echo "--- Setup di $CURRENT_HOST Selesai ---"