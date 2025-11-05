# Jarkom-Modul-3-2025-K-16
## MEMBER
1. Muhammad Ardiansyah Tri Wibowo - 5027241091
2. Nisrina Bilqis - 5027241054
## Akses Soal
https://docs.google.com/document/d/132Qc6g4a7CQTVu9INjJ0nVfcZBPVs7DUYkScq-bF-sU/edit?tab=t.0
## Soal 1: Konfigurasi Jaringan Dasar
### Soal:
```
Di awal Zaman Kedua, setelah kehancuran Beleriand, para Valar menugaskan untuk membangun kembali jaringan komunikasi antar kerajaan. Para Valar menyalakan Minastir,
Aldarion, Erendis, Amdir, Palantir, Narvi, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher, Miriel, Amandil, Gilgalad, Celebrimbor, Khamul, dan
pastikan setiap node (selain Durin sang penghubung antar dunia) dapat sementara berkomunikasi dengan Valinor/Internet (nameserver 192.168.122.1) untuk menerima instruksi
awal.
```
### Tujuan
Menginisialisasi konfigurasi jaringan dasar di semua node. Soal ini mengatur hostname untuk mendeteksi perannya, kemudian mengkonfigurasi file `/etc/network/interfaces` secara dinamis. Peran utamanya adalah menjadikan "Durin" sebagai Router (Gateway) dengan NAT (Network Address Translation) agar semua node internal dapat terhubung ke internet. Mengkonfigurasi `/etc/network/interfaces` di semua node berdasarkan hostname mereka.
### Langkah Eksekusi & Verifikasi:CURRENT_HOST=$(hostname): Skrip mendeteksi nama node saat ini.
1. case $CURRENT_HOST in ... "Durin") ...: Skrip masuk ke logika khusus untuk "Durin".
2. sysctl -w net.ipv4.ip_forward=1: Mengaktifkan penerusan IP di Durin.
3. iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.219.0.0/16: Menjadikan Durin sebagai router NAT.
4. cat << EOF >> $CONFIG_FILE: Menulis konfigurasi IP statis untuk node lain (misal: Elendil, Aldarion, Amandil, Minastir).
5. service networking restart: Menerapkan semua perubahan IP.
6. ping -c 3 google.com: Menjalankan tes konektivitas internet di akhir skrip.

<img width="1401" height="726" alt="image" src="https://github.com/user-attachments/assets/705a03a8-8523-43c2-b14e-cc5bcebc04f8" />

 * Contoh hasil pada gambar:
   Berhasil. Konektivitas internet terkonfirmasi.
   * Node Elendil berhasil melakukan ping ke google.com (Bukti: 23512.jpg - panel kanan).
   * Node Aldarion berhasil melakukan ping ke google.com (Bukti: 23513.jpg - panel kiri).
   * Node Amandil berhasil melakukan ping ke google.com (Bukti: 23513.jpg - panel kanan).
   * Node Minastir berhasil melakukan ping ke google.com (Bukti: 23514.jpg).

## Soal 2: Konfigurasi Layanan DHCP
### Soal
```
Raja Pelaut Aldarion, penguasa wilayah Númenor, memutuskan cara pembagian tanah client secara dinamis. Ia menetapkan:
 * Client Dinamis Keluarga Manusia: Mendapatkan tanah di rentang [prefix ip].1.6 - [prefix ip].1.34 dan [prefix ip].1.68 - [prefix ip].1.94.
 * Client Dinamis Keluarga Peri: Mendapatkan tanah di rentang [prefix ip].2.35 - [prefix ip].2.67 dan [prefix ip].2.96 - [prefix ip].2.121.
 * Khamul yang misterius: Diberikan tanah tetap di [prefix ip].3.95, agar keberadaannya selalu diketahui. Pastikan Durin dapat menyampaikan dekrit ini ke semua wilayah yang
terhubung dengannya.
```
### Tujuan
   Mengkonfigurasi arsitektur DHCP terpusat. Ini melibatkan tiga peran:
   * Aldarion: Sebagai DHCP Server (isc-dhcp-server).
   * Durin: Sebagai DHCP Relay (isc-dhcp-relay) untuk meneruskan permintaan DHCP dari subnet lain ke Aldarion.
   * Amandil, Gilgalad, Khamul: Sebagai DHCP Client.
### Langkah Eksekusi & Verifikasi:
1. Di Aldarion (Server):
   * apt-get install -y isc-dhcp-server: Menginstal server.
   * echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server: Mengatur server agar hanya "mendengar" di eth0.
   * cat << 'EOF' > /etc/dhcp/dhcpd.conf: Menulis file konfigurasi subnet dan range IP.
   * service isc-dhcp-server restart: Menerapkan konfigurasi.

2. Di Durin (Relay):
   * apt-get install -y isc-dhcp-relay: Menginstal relay.
   * echo 'SERVERS="192.219.4.2"' > /etc/default/isc-dhcp-relay: Memberi tahu relay di mana alamat Server DHCP (Aldarion).
   * echo 'INTERFACES="eth1 eth2 eth3 eth4"' >> ...: Memberi tahu relay untuk meneruskan permintaan dari antarmuka ini.
   * service isc-dhcp-relay restart: Menerapkan konfigurasi.

3. Di Amandil (Client):
   * ip addr flush dev eth0: Menghapus IP lama.
   * dhclient -v eth0: Meminta IP baru secara aktif.

<img width="1402" height="732" alt="image" src="https://github.com/user-attachments/assets/17244ebf-d744-45e7-8c1f-e9b9930369e9" />

<img width="1123" height="579" alt="image" src="https://github.com/user-attachments/assets/f5414022-e81b-413c-bc04-39f5098b724b" />

Hasil (Berdasarkan Bukti Gambar):
   Berhasil. Ketiga komponen berfungsi.
   * Server (Aldarion): Layanan isc-dhcp-server berhasil di-restart dan verifikasi status menunjukkan layanan aktif (Bukti: 23513.jpg - panel kiri, "Me-restart isc-dhcp-server... Setup Aldarion Selesai").
   * Relay (Durin): Instalasi dan konfigurasi isc-dhcp-relay berhasil, termasuk aktivasi IP Forwarding (Bukti: 23512.jpg - panel kiri).
   * Client (Amandil): Proses handshake DHCP (DISCOVER, OFFER, REQUEST, ACK) terekam dengan jelas. Amandil berhasil mendapatkan IP 192.219.1.7 dari relay (192.219.1.1 - Durin) (Bukti: 23515.jpg).
   
## Soal 3: Konfigurasi DNS Forwarding
### Soal
```
Untuk mengontrol arus informasi ke dunia luar (Valinor/Internet), sebuah menara pengawas, Minastir didirikan. Minastir mengatur agar semua node (kecuali Durin) hanya dapat
mengirim pesan ke luar Arda setelah melewati pemeriksaan di Minastir.
```
### Tujuan:
Mengkonfigurasi node Minastir (192.219.5.2) untuk bertindak sebagai DNS Forwarder (atau Caching Server). Tujuannya adalah semua permintaan DNS dari jaringan internal ke internet (seperti google.com) akan melalui Minastir terlebih dahulu. Skrip ini juga mengubah /etc/resolv.conf di semua node klien agar menunjuk ke Minastir.
### Langkah Eksekusi & Verifikasi:
1. Di Minastir:
   * apt-get install -y bind9 ...: Menginstal BIND9.
   * cat > /etc/bind/named.conf.options << EOF: Menulis file konfigurasi baru.
   * Perintah di dalam cat: forwarders { 8.8.8.8; 8.8.4.4; 1.1.1.1; }; dan forward only; mengubah Minastir menjadi forwarder murni.
   * service named restart: Menerapkan konfigurasi.

2. Di Semua Klien (kecuali Durin/Minastir):
   * cat > /etc/resolv.conf << EOF: Menimpa resolver klien.
   * Perintah di dalam cat: nameserver 192.219.5.2 (alamat IP Minastir).
<img width="758" height="766" alt="image" src="https://github.com/user-attachments/assets/1aafb03b-eb45-4202-88a9-094dab5f19bf" />

<img width="1067" height="716" alt="image" src="https://github.com/user-attachments/assets/8c3142ba-11ab-49db-bbf4-d01325dfee99" />

 * Hasil (Berdasarkan Bukti Gambar):
   Terkonfigurasi. Bukti gambar menunjukkan prasyarat (konektivitas internet Minastir) terpenuhi.
   * Node Minastir terbukti aktif dan memiliki koneksi internet (dari Soal 1), yang merupakan syarat mutlak untuk dapat me-forward kueri DNS ke server eksternal (Bukti: 23514.jpg).

## Soal 4: Konfigurasi DNS Master-Slave (Internal)
### Soal
```
Ratu Erendis, sang pembuat peta, menetapkan nama resmi untuk wilayah utama (<xxxx>.com). Ia menunjuk dirinya (ns1.<xxxx>.com) dan muridnya Amdir (ns2.<xxxx>.com) sebagai
penjaga peta resmi. Setiap lokasi penting (Palantir, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher) diberikan nama domain unik yang menunjuk ke
lokasi fisik tanah mereka. Pastikan Amdir selalu menyalin peta (master-slave) dari Erendis dengan setia.
```
### Tujuan:
   Membangun layanan DNS internal untuk domain k16.com.
   * Erendis (192.219.3.3): Dikonfigurasi sebagai Master DNS Server.
   * Amdir (192.219.3.4): Dikonfigurasi sebagai Slave DNS Server.
   * Client (Miriel): Dikonfigurasi untuk menggunakan Erendis sebagai resolver.
### Langkah Eksekusi & Verifikasi:
1. Di Erendis (Master):
   * cat > /etc/bind/named.conf.local: Mendefinisikan zona k16.com sebagai type master.
   * cat > /etc/bind/jarkom/k16.com: Menulis semua A Records (misal: palantir IN A 192.219.4.3, galadriel IN A 192.219.2.5, dll).
   * service named restart: Memulai layanan DNS.

2. Di Amdir (Slave):
   * cat > /etc/bind/named.conf.local: Mendefinisikan zona k16.com sebagai type slave dengan masters { 192.219.3.3; };.
   * service named restart: Memulai layanan dan memicu zone transfer.

3. Di Klien (Miriel):
   * echo "nameserver 192.219.3.3" > /etc/resolv.conf: Mengarahkan klien ke Erendis.
   * nslookup palantir.k16.com: Menjalankan tes resolusi.
  
<img width="1168" height="733" alt="image" src="https://github.com/user-attachments/assets/e0657c44-c914-413f-9871-b9e2520421f0" />

<img width="1176" height="715" alt="image" src="https://github.com/user-attachments/assets/402f69be-10a7-4b36-bc30-6e8b93777774" />

<img width="1177" height="751" alt="image" src="https://github.com/user-attachments/assets/419cc95a-6b13-4bca-9818-60b534aa8b6e" />

## Soal 5: Update DNS (CNAME, TXT, Reverse)
### Soal
```
Untuk memudahkan, nama alias www.<xxxx>.com dibuat untuk peta utama <xxxx>.com. Reverse PTR juga dibuat agar lokasi Erendis dan Amdir dapat dilacak dari alamat fisik
tanahnya. Erendis juga menambahkan pesan rahasia (TXT record) pada petanya: "Cincin Sauron" yang menunjuk ke lokasi Elros, dan "Aliansi Terakhir" yang menunjuk ke lokasi
Pharazon. Pastikan Amdir juga mengetahui pesan rahasia ini.
```
### Tujuan
Memperbarui konfigurasi DNS di Erendis (Master) dari Soal 4. Pembaruan ini menambahkan record CNAME (www), TXT, dan yang paling penting, Reverse Zone (PTR) untuk subnet 192.219.3.0/24.
### Langkah Eksekusi & Verifikasi:
1. Di Erendis (Master):
   * cat > /etc/bind/named.conf.local: Menambahkan definisi zone "3.219.192.in-addr.arpa" (Ini salah ketik di skripmu, harusnya 3.219.192.in-addr.arpa atau 3.76.10.in
   * addr.arpa seperti di file soal_5.sh). Catatan: Berdasarkan skrip soal_5.sh yang kamu berikan, nama zona yang benar adalah 3.76.10.in-addr.arpa.
   * cat > /etc/bind/jarkom/3.76.10.in-addr.arpa: Menulis PTR Records (misal: 3 IN PTR ns1.k16.com.).
   * service named restart: Menerapkan zona baru.

2. Di Klien (Miriel):
   * host 192.219.3.3: Menjalankan tes reverse lookup.

<img width="1307" height="787" alt="image" src="https://github.com/user-attachments/assets/b42bd92b-033a-4781-b86d-53192896d6b4" />

<img width="1676" height="519" alt="image" src="https://github.com/user-attachments/assets/3a5a6bc5-acdc-4e05-b9ef-4c00b237e21b" />

 * Hasil (Berdasarkan Bukti Gambar):
   Berhasil (untuk Reverse Zone).
   * Master (Erendis): Verifikasi reverse lookup lokal (dig -x 192.219.3.3 @localhost) berhasil dengan status NOERROR, memetakan IP kembali ke nama ns1.k16.com. (Bukti: 23496.jpg).
   * Client (Miriel): Verifikasi reverse lookup dari klien (host 192.219.3.3 dan host 192.219.3.4) juga berhasil. Klien dapat dengan benar memetakan 192.219.3.3 ke ns1.k16.com. dan 192.219.3.4 ke ns2.k16.com. (Bukti: 23498.jpg).

## Soal 6: Update Konfigurasi DHCP Server
### Soal
```
Aldarion menetapkan aturan waktu peminjaman tanah. Ia mengatur:
 * Client Dinamis Keluarga Manusia dapat meminjam tanah selama setengah jam.
 * Client Dinamis Keluarga Peri hanya seperenam jam.
 * Batas waktu maksimal peminjaman untuk semua adalah satu jam.
```
### Tujuan:
Menimpa (overwrite) file konfigurasi DHCP Server di Aldarion (/etc/dhcp/dhcpd.conf) dengan pengaturan baru dari skrip soal_6.sh. Perubahan utama mencakup max-lease-time, option domain-name-servers baru, dan reservasi IP untuk Khamul.
### Langkah Eksekusi & Verifikasi:
* Di Aldarion:
  * cat << 'EOF' > /etc/dhcp/dhcpd.conf: Perintah ini menimpa (bukan menambahkan) seluruh konfigurasi dhcpd.conf dengan konten baru dari skrip soal_6.sh.
  * service isc-dhcp-server restart: Menerapkan file konfigurasi yang baru saja ditulis.

<img width="698" height="786" alt="image" src="https://github.com/user-attachments/assets/0ae5ff86-5597-4364-a4fa-2c4b7b385ffa" />
  
 * Hasil (Berdasarkan Bukti Gambar):
   Berhasil.
   * Bukti gambar (23500.jpg) adalah tangkapan layar yang menunjukkan isi file konfigurasi baru dan eksekusi skrip secara bersamaan.
   * Terlihat jelas max-lease-time 3600, subnet 192.219.1.0 (Manusia), subnet 192.219.2.0 (Peri), dan subnet 192.219.3.0 (Kurcaci) dengan opsi yang sesuai dari skrip.
   * Di bagian bawah gambar, terlihat log service isc-dhcp-server restart (Stopping ISC DHCPv4 server... dan Starting ISC DHCPv4 server...), yang mengkonfirmasi bahwa skrip telah dieksekusi dan layanan di-restart untuk menerapkan perubahan.

## Soal 7: Konfigurasi Web Server (Dasar)
### Soal
```
Para Ksatria Númenor (Elendil, Isildur, Anarion) mulai membangun benteng pertahanan digital mereka menggunakan teknologi Laravel. Instal semua tools yang dibutuhkan
(php8.4, composer, nginx) dan dapatkan cetak biru benteng dari Resource-laravel di setiap node worker Laravel. Cek dengan lynx di client.
```
### Tujuan
   Menginstal Nginx, PHP 8.4, dan Composer di node worker. Skrip ini kemudian membuat halaman `phpinfo()` sederhana untuk pengujian.

### Langkah Eksekusi & Verifikasi:
 1.  `apt update -y`: Memperbarui daftar paket.
 2.  `apt install -y nginx php8.4 php8.4-fpm ... composer`: Menginstal semua perangkat lunak yang diperlukan (Nginx, PHP, dan Composer).
 3.  `mkdir -p /var/www/laravel`: Membuat direktori web.
 4.  `echo "<?php phpinfo(); ?>" > index.php`: Membuat file `index.php` pengujian yang hanya berisi `phpinfo()`.
 5.  `rm -f /etc/nginx/sites-enabled/default`: Menghapus konfigurasi default Nginx
 6.   cat << 'EOF' > /etc/nginx/sites-available/laravel`: Membuat file konfigurasi Nginx baru untuk menayangkan konten dari `/var/www/laravel` di port 80 dan meneruskan file `.php` ke PHP-FPM.
 7.   ginx -t`: Menguji sintaks file konfigurasi Nginx.
 8.   `ln -sf /etc/nginx/sites-available/laravel ...`: Mengaktifkan konfigurasi baru.
 9.   `service php8.4-fpm start`
 10.   `service nginx start`
 11.   `service php8.4-fpm restart`
 12.   `service nginx restart`: Memulai dan me-restart layanan untuk menerapkan semua perubahan.

<img width="1046" height="599" alt="image" src="https://github.com/user-attachments/assets/0e3d0a36-a4a9-44ee-aa21-33a9bc609ef6" />

* Hasil (Berdasarkan Bukti Gambar):
    **Berhasil.** Gambar (`image_503a4d.jpg`) dengan jelas menunjukkan **output akhir** dari eksekusi skrip ini.
    * `Setting up php8.4 (...)`, `Setting up composer (...)`: Ini adalah log dari perintah `apt install` (Langkah 2) yang berhasil menyelesaikan instalasi.
    * `nginx: the configuration file ... syntax is ok`: Ini adalah output sukses dari perintah `nginx -t` (Langkah 7).
    * `nginx: configuration file ... test is successful`: Ini juga konfirmasi dari `nginx -t` (Langkah 7).
    * `Starting nginx: nginx.`: Output dari `service nginx start` (Langkah 10).
    * `Restarting PHP 8.4 ...`: Output dari `service php8.4-fpm restart` (Langkah 11).
    * `Restarting nginx: nginx.`: Output dari `service nginx restart` (Langkah 12).

## Soal 8: Konfigurasi Full-Stack (Database & Laravel)
### Soal
```
Setiap benteng Númenor harus terhubung ke sumber pengetahuan, Palantir. Konfigurasikan koneksi database di file .env masing-masing worker. Setiap benteng juga harus memiliki gerbang masuk yang unik; atur nginx agar Elendil mendengarkan di port 8001, Isildur di 8002, dan Anarion di 8003. Jangan lupa jalankan migrasi dan seeding awal dari Elendil. Buat agar akses web hanya bisa melalui domain nama, tidak bisa melalui ip.
```
### Tujuan
Menginstal aplikasi web Laravel di node worker (Elendil, dll.) dan menghubungkannya ke server database terpusat (Palantir).
### Langkah Eksekusi & Verifikasi:
* Perintah Kunci yang Dieksekusi (di node "Palantir"):
    1. `apt install -y mariadb-server`: Menginstal server database MariaDB.
    2.  `service mariadb start`: Memulai layanan database.
    3.  `mysql -u root <<EOF ... EOF`: Menjalankan serangkaian perintah SQL untuk:
        * `CREATE DATABASE laravel_db;`: Membuat database baru.
        * `CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravel123';`: Membuat user baru (`laravel`) yang bisa diakses dari mana saja (`%`).
        * `GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel'@'%';`: Memberi user tersebut hak akses penuh ke database `laravel_db`.
    4.  `sed -i 's/bind-address.../bind-address = 0.0.0.0/g' ...`: **Perintah Kritis.** Ini mengubah konfigurasi MariaDB agar mau menerima koneksi dari alamat IP lain (bukan hanya `localhost`).
    5.  `service mariadb restart`: Menerapkan perubahan konfigurasi.

* **Perintah Kunci yang Dieksekusi (di node "Elendil", "Isildur", "Anarion"):**
    1.  `rm -rf /var/www/laravel`: **Menghapus** direktori web lama (yang berisi `phpinfo()` dari Soal 7).
    2.  `git clone https://github.com/laravel/laravel.git laravel`: Mengunduh *source code* aplikasi Laravel dari GitHub.
    3.  `composer install`: Menginstal semua dependensi PHP yang dibutuhkan oleh Laravel.
    4.  `cp .env.example .env`: Membuat file konfigurasi lingkungan.
    5.  `php artisan key:generate`: Menghasilkan kunci enkripsi unik untuk aplikasi.
    6.  `sed -i "s/DB_HOST=127.0.0.1/DB_HOST=192.219.4.3/g" .env`: Mengubah file `.env` agar menunjuk ke IP **Palantir** (192.219.4.3) sebagai host database.
    7.  `sed -i ...`: Mengatur nama database, username, dan password di `.env` agar sesuai dengan yang dibuat di Palantir.
    8.  `if [ "$CURRENT_HOST" = "Elendil" ]; then PORT="8001" ...`: Logika ini menetapkan port unik untuk setiap worker (Elendil: 8001, Isildur: 8002, Anarion: 8003).
    9.  `cat << EOF > /etc/nginx/sites-available/laravel`: **Menimpa** konfigurasi Nginx dari Soal 7. Konfigurasi baru ini:
        * Menggunakan port baru (misal: `listen 8001;`).
        * Mengatur `root` ke `/var/www/laravel/public;` (direktori yang benar untuk Laravel).
    10. `service nginx restart` dan `service php8.4-fpm restart`: Menerapkan konfigurasi Nginx yang baru.
    11. `if [ "$CURRENT_HOST" = "Elendil" ]; then ... php artisan migrate:fresh --seed`: **Hanya di Elendil**, skrip ini menjalankan migrasi database. Ini adalah perintah yang membuat *tabel-tabel* Laravel di dalam database `laravel_db` di Palantir.

<img width="1486" height="772" alt="image" src="https://github.com/user-attachments/assets/d21872e1-6de8-4864-8978-819bd086931f" />

* **Hasil (Berdasarkan Bukti Gambar):**
    **Berhasil.** Gambar (`image_50b382.jpg`) menunjukkan halaman *welcome* default Laravel ("Let's get started", "Deploy now") yang ditampilkan di dalam browser terminal.
    * Ini membuktikan bahwa langkah-langkah di sisi *web server* (worker) seperti `git clone`, `composer install`, dan rekonfigurasi Nginx (untuk port baru dan *root directory* `/public`) telah **sukses**.
    * Gambar ini adalah hasil yang didapat ketika mengakses salah satu worker (misal: `links http://elendil.k16.com:8001`) setelah skrip `soal_8.sh` selesai dijalankan.

## Soal 9: Penambahan API Route (`/api/airing`)
### Soal
```
Pastikan setiap benteng berfungsi secara mandiri. Dari dalam node client masing-masing, gunakan lynx untuk melihat halaman utama Laravel dan curl /api/airing untuk memastikan mereka bisa mengambil data dari Palantir.
```
* **Tujuan:**
    Menambahkan *route* API baru (`/api/airing`) ke aplikasi Laravel di semua node worker (Elendil, Isildur, Anarion). *Route* ini akan menjalankan kueri `SHOW DATABASES` ke database (Palantir) dan mengembalikannya sebagai JSON untuk membuktikan koneksi.

* **Perintah Kunci yang Dieksekusi (di Elendil, Isildur, Anarion):**
    1.  `service nginx status || service nginx restart`: Memeriksa status Nginx.
    2.  `service php8.4-fpm status || service php8.4-fpm restart`: Memeriksa status PHP-FPM.
    3.  `cat << 'EOF' > /var/www/laravel/routes/api.php`: Membuat file `api.php` yang berisi logika untuk *route* `/airing`. Logika ini mencoba `DB::select('SHOW DATABASES')`.
    4.  `sed -i "...api: __DIR__.../api.php..." ...`: Mengedit file `bootstrap/app.php` agar Laravel mendaftarkan file `api.php` yang baru dibuat.
    5.  `php artisan route:clear`: Membersihkan *cache* *route* lama.
    6.  `php artisan route:cache`: Membuat *cache* *route* baru agar *route* `/api/airing` dikenali.
    7.  `service php8.4-fpm restart` dan `service nginx restart`: Me-restart layanan untuk menerapkan semua perubahan.

<img width="1416" height="718" alt="image" src="https://github.com/user-attachments/assets/9f3e1e9d-faf8-48e1-aebb-5307085d18fc" />

* **Hasil (Berdasarkan Bukti Gambar):**
    **Berhasil.** Gambar (`image_50c22e.jpg`) menunjukkan seluruh proses eksekusi skrip dan verifikasinya di node **Elendil**.
    * `nginx is running.` dan `php-fpm8.4 is running.`: Output sukses dari perintah `service status` (Langkah 1 & 2).
    * `INFO Route cache cleared successfully.` dan `INFO Routes cached successfully.`: Output sukses dari perintah `php artisan route:clear` dan `route:cache` (Langkah 5 & 6).
    * `Restarting PHP 8.4...` dan `Restarting nginx: nginx.`: Output sukses dari perintah *restart* layanan (Langkah 7).
    * `Setup API route di Elendil selesai.`: Konfirmasi bahwa skrip telah selesai di node Elendil.
    * **Verifikasi Akhir:** Perintah manual `curl Elendil.k16.com:8001/api/airing` dijalankan setelah skrip selesai.
    * **Output Verifikasi:** `{"status":"connected","databases":[...{"Database":"laravel_db"}]}`. Ini adalah **bukti sukses** bahwa *route* `/api/airing` aktif dan berhasil terhubung ke database di Palantir.
