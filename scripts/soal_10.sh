#!/bin/bash

# Script ini mengkonfigurasi Elros sebagai Nginx Reverse Proxy
# untuk mendistribusikan traffic ke node worker (Elendil, Isildur, Anarion).

# --- 1. Instalasi Nginx ---
apt update -y
apt install -y nginx

# --- 2. Konfigurasi Reverse Proxy ---
# Menulis file konfigurasi Nginx untuk reverse proxy
cat << 'EOF' > /etc/nginx/sites-available/reverse-proxy
# ============================
# Reverse Proxy - Elros
# ============================

# Mendefinisikan 'upstream' (grup server backend)
# Nginx akan me-load balance request ke server-server ini (default: round-robin)
upstream kesatria_numenor {
    server 192.219.1.2:8001;    # Elendil
    server 192.219.1.3:8002;    # Isildur
    server 192.219.1.4:8003;    # Anarion
}

server {
    listen 80;
    server_name elros.k32.com;

    # Semua request (location /) akan diteruskan
    location / {
        # Meneruskan (pass) request ke grup upstream 'kesatria_numenor'
        proxy_pass http://kesatria_numenor;

        # Mengatur header agar server backend (Laravel)
        # menerima informasi host dan IP asli dari client,
        # bukan IP dari si Elros (proxy)
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Menentukan file log custom untuk server ini
    access_log /var/log/nginx/elros-access.log;
    error_log  /var/log/nginx/elros-error.log;
}
EOF

# --- 3. Aktivasi Konfigurasi ---
# Membuat symlink untuk mengaktifkan site
# (Menggunakan -sf untuk force/timpa jika ada link 'default')
ln -sf /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/

# Tes sintaks konfigurasi Nginx
nginx -t

# Menerapkan konfigurasi dengan me-restart Nginx
service nginx restart