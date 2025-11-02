# ==========================================================
# == Script Update Nginx Param & index.php (Show Real IP) ==
# ==                                                      ==
# == Script ini akan:                                     ==
# == 1. Menambahkan fastcgi_param HTTP_X_REAL_IP          ==
# == 2. Meng-update index.php untuk menampilkan IP asli   ==
# ==========================================================

CONFIG_FILE="/etc/nginx/sites-available/php-worker"
PHP_FILE="/var/www/html/index.php"

# --- 1. Modifikasi Konfigurasi Nginx ---
echo "Menambahkan fastcgi_param HTTP_X_REAL_IP ke $CONFIG_FILE..."

# Menggunakan 'sed' untuk menyisipkan baris baru
# tepat setelah baris 'include snippets/fastcgi-php.conf;'
sed -i "/include snippets\/fastcgi-php.conf;/a \        fastcgi_param HTTP_X_REAL_IP \$remote_addr;" "$CONFIG_FILE"

# --- 2. Aktivasi & Restart Nginx ---
echo "Mengecek sintaks Nginx..."
nginx -t

echo "Me-restart Nginx..."
service nginx restart

# --- 3. Update File index.php ---
echo "Meng-update $PHP_FILE untuk menampilkan IP pengunjung..."

# Menimpa file index.php dengan konten baru
cat << 'EOF' > $PHP_FILE
<?php
$hostname = gethostname();
// Ambil IP dari header X-REAL-IP (jika ada), jika tidak, pakai REMOTE_ADDR
$visitor_ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'];

echo "Welcome to taman digital $hostname.<br>";
echo "Anda (Sang Pengunjung) datang dari alamat IP: $visitor_ip";
?>
EOF

echo "--- Update Selesai ---"
echo "Silakan tes ulang dari client (Gilgalad)."