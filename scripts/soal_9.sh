# Script ini mengkonfigurasi route API baru (/api/airing)
# di semua node worker (Elendil, Isildur, Anarion)
# untuk memverifikasi koneksi database.

# --- 1. Pengecekan dan Restart Service ---
# Memastikan service Nginx dan PHP-FPM berjalan.
# Perintah '||' akan menjalankan 'restart' HANYA JIKA 'status'
# mengembalikan error (misalnya, service-nya mati).
echo "Memeriksa status service..."
service nginx status || service nginx restart
service php8.4-fpm status || service php8.4-fpm restart

# --- 2. Membuat File API Route ---
# Menulis file route baru di routes/api.php.
# Route ini akan mencoba query 'SHOW DATABASES' ke database
# dan mengembalikannya sebagai JSON.
echo "Membuat route /api/airing..."
cat << 'EOF' > /var/www/laravel/routes/api.php
<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::get('/airing', function () {
    try {
        // Menjalankan query sederhana untuk tes koneksi
        $data = DB::select('SHOW DATABASES');
        return response()->json([
            'status' => 'connected',
            'databases' => $data
        ]);
    } catch (\Exception $e) {
        // Menangkap error jika koneksi gagal
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500); // Memberi status 500 jika error
    }
});
EOF

# --- 3. Registrasi File API Route ---
# Mengedit file bootstrap/app.php untuk mendaftarkan api.php
# agar route di dalamnya dikenali oleh Laravel.
echo "Mendaftarkan file api.php di bootstrap/app.php..."

# Menggunakan sed untuk menambahkan baris 'api: ...'
# tepat di bawah baris 'web: ...'
sed -i "/web: __DIR__.'\/..\/routes\/web.php',/a \    api: __DIR__.'\/..\/routes\/api.php'," /var/www/laravel/bootstrap/app.php

# --- 4. Update Cache Route Laravel ---
# Pindah ke direktori project
cd /var/www/laravel

# Membersihkan cache route lama dan membuat cache baru
# agar route /api/airing terdeteksi.
echo "Membersihkan dan membuat cache route baru..."
php artisan route:clear
php artisan route:cache

# (Opsional) Menampilkan daftar route untuk konfirmasi
# php artisan route:list

# --- 5. Restart Service ---
# Me-restart service agar semua perubahan (file PHP dan cache)
# di-load dengan benar.
echo "Me-restart service..."
service php8.4-fpm restart
service nginx restart

echo "Setup API route di $(hostname) selesai."