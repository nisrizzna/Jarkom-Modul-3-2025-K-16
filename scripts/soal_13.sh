#!/bin/bash

# ==========================================================
# == Script Update Port PHP Worker (Galadriel, Celeborn, Oropher) ==
# ==                                                      ==
# == Script ini mengubah port 'listen' di Nginx           ==
# == berdasarkan hostname server.                         ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)
CONFIG_FILE="/etc/nginx/sites-available/php-worker"
PORT=""

# Tentukan port berdasarkan nama host
case $CURRENT_HOST in
    "Galadriel")
        PORT="8004"
        ;;
    "Celeborn")
        PORT="8005"
        ;;
    "Oropher")
        PORT="8006"
        ;;
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali."
        echo "Script ini hanya untuk Galadriel, Celeborn, atau Oropher."
        exit 1
        ;;
esac

# --- 1. Modifikasi File Konfigurasi ---
echo "Mengubah port di $CONFIG_FILE menjadi $PORT untuk $CURRENT_HOST..."

# Menggunakan sed untuk mencari 'listen 80;' dan menggantinya
# dengan 'listen [PORT];'
# (Asumsi port sebelumnya adalah 80)
sed -i "s/listen 80;/listen $PORT;/g" $CONFIG_FILE

# --- 2. Aktivasi & Restart ---
echo "Mengecek sintaks Nginx..."
nginx -t

# Me-restart service untuk menerapkan perubahan
echo "Me-restart Nginx dan PHP-FPM..."
service nginx restart
service php8.4-fpm restart

echo "--- Update port di $CURRENT_HOST Selesai ---"
echo "Server $CURRENT_HOST sekarang listening di port $PORT."