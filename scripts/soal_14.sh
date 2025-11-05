# ==========================================================
# == Script Setup HTTP Basic Auth (Galadriel, Celeborn, Oropher) ==
# ==                                                      ==
# == Script ini menambahkan autentikasi dasar (htpasswd)    ==
# == ke server Nginx.                                     ==
# ==========================================================

# --- Variabel Konfigurasi ---
CONFIG_FILE="/etc/nginx/sites-available/php-worker"
PASS_FILE="/etc/nginx/.htpasswd"
USER="noldor"
PASS="silvan"

# --- 1. Install apache2-utils ---
# Dibutuhkan untuk perintah 'htpasswd'
echo "Menginstall apache2-utils..."
apt update -y
apt install -y apache2-utils

# --- 2. Buat File Password ---
# -c = Create (membuat file baru, menimpa jika sudah ada)
# -b = Batch mode (baca password dari command line, non-interaktif)
echo "Membuat file password di $PASS_FILE untuk user $USER..."
htpasswd -cb $PASS_FILE $USER $PASS

# --- 3. Modifikasi Konfigurasi Nginx ---
# Menambahkan baris auth_basic... di bawah 'server_name'
echo "Menambahkan konfigurasi Basic Auth ke $CONFIG_FILE..."

# Menggunakan 'sed' untuk menyisipkan 2 baris
# tepat setelah baris yang mengandung 'server_name .*k16.com;'
# '\n' digunakan untuk memisahkan dua baris yang ditambahkan.
sed -i "/server_name .*k16.com;/a \    auth_basic \"Akses Terbatas: Gerbang Taman Peri\";\n    auth_basic_user_file \/etc\/nginx\/.htpasswd;" "$CONFIG_FILE"

# --- 4. Aktivasi & Restart ---
echo "Mengecek sintaks Nginx..."
nginx -t

echo "Me-restart Nginx..."
service nginx restart

echo "--- Setup Basic Auth Selesai ---"