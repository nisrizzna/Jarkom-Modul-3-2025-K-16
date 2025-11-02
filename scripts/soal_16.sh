# ==========================================================
# == Script Setup Nginx Reverse Proxy (Pharazon)          ==
# ==                                                      ==
# == Script ini mengkonfigurasi Pharazon sebagai           ==
# == Load Balancer untuk worker Lorien (Galadriel, dll.)  ==
# == dan meneruskan (forward) Basic Authentication.       ==
# ==========================================================

# --- 1. Instalasi Nginx ---
echo "Menginstall Nginx..."
apt update -y
apt install -y nginx

# --- 2. Hapus Konfigurasi Default ---
rm -f /etc/nginx/sites-enabled/default

# --- 3. Buat Konfigurasi Load Balancer ---
echo "Membuat file konfigurasi /etc/nginx/sites-available/pharazon-lb..."

# Menggunakan 'cat' untuk menulis file konfigurasi
# 'EOF' dibungkus petik agar variabel Nginx ($host, $remote_addr)
# tidak dievaluasi oleh shell
cat << 'EOF' > /etc/nginx/sites-available/pharazon-lb
# 1. DEFINE UPSTREAM (Load Balancer Group)
upstream Kesatria_Lorien {
    # Menggunakan algoritma default (Round Robin)
    server 192.219.2.5:8004;  # Galadriel
    server 192.219.2.6:8005;  # Celeborn
    server 192.219.2.7:8006;  # Oropher
}

# 2. SERVER BLOCK (Reverse Proxy)
server {
    listen 80;
    server_name pharazon.k32.com;

    location / {
        # Meneruskan permintaan ke kelompok worker
        proxy_pass http://Kesatria_Lorien;

        # Meneruskan IP asli klien ke worker (worker akan melihat ini)
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # --- PENTING: Meneruskan Basic Auth & IP Asli ---
        # Meneruskan header Basic Authentication (Authorization)
        # $http_authorization berisi kredensial yang dikirim oleh client
        proxy_set_header Authorization $http_authorization;
        # --------------------------------------------------
    }

    # Log opsional untuk debugging
    # access_log /var/log/nginx/pharazon-access.log;
    # error_log /var/log/nginx/pharazon-error.log;
}
EOF

# --- 4. Aktivasi Konfigurasi & Restart ---
echo "Mengaktifkan site baru dan me-restart Nginx..."

# Mengaktifkan konfigurasi baru (-sf = symbolic, force)
ln -sf /etc/nginx/sites-available/pharazon-lb /etc/nginx/sites-enabled/

# Tes sintaks konfigurasi
nginx -t

# Menerapkan perubahan
service nginx restart

echo "--- Setup Pharazon Load Balancer Selesai ---"