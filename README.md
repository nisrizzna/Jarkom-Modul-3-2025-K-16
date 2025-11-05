# Jarkom-Modul-3-2025-K-16

## Soal 1: Konfigurasi Jaringan Dasar
### Tujuan
Menginisialisasi konfigurasi jaringan dasar di semua node. Skrip ini mengatur hostname untuk mendeteksi perannya, kemudian mengkonfigurasi file /etc/network/interfaces secara dinamis. Peran utamanya adalah menjadikan "Durin" sebagai Router (Gateway) dengan NAT (Network Address Translation) agar semua node internal dapat terhubung ke internet.
### Langkah Eksekusi & Verifikasi:
   * Skrip soal_1.sh dieksekusi di semua node.
   * Di Durin, skrip mengaktifkan ip_forward dan iptables MASQUERADE.
   * Di node lain (misal: Elendil, Aldarion, Amandil, Minastir), skrip mengatur IP (statis atau DHCP) dan menempatkan Durin sebagai gateway.
   * Langkah verifikasi akhir dalam skrip adalah menjalankan ping google.com untuk memastikan konektivitas internet melalui NAT di Durin.
 * Hasil (Berdasarkan Bukti Gambar):
   Berhasil. Konektivitas internet terkonfirmasi.
   * Node Elendil berhasil melakukan ping ke google.com (Bukti: 23512.jpg - panel kanan).
   * Node Aldarion berhasil melakukan ping ke google.com (Bukti: 23513.jpg - panel kiri).
   * Node Amandil berhasil melakukan ping ke google.com (Bukti: 23513.jpg - panel kanan).
   * Node Minastir berhasil melakukan ping ke google.com (Bukti: 23514.jpg).

## Soal 2: Konfigurasi Layanan DHCP
### Tujuan
   Mengkonfigurasi arsitektur DHCP terpusat. Ini melibatkan tiga peran:
   * Aldarion: Sebagai DHCP Server (isc-dhcp-server).
   * Durin: Sebagai DHCP Relay (isc-dhcp-relay) untuk meneruskan permintaan DHCP dari subnet lain ke Aldarion.
   * Amandil, Gilgalad, Khamul: Sebagai DHCP Client.
### Langkah Eksekusi & Verifikasi:
   * DHCP Server (Aldarion): Skrip soal_2.sh diinstal dan dijalankan di Aldarion.
   * DHCP Relay (Durin): Skrip soal_2.sh diinstal dan dijalankan di Durin.
   * DHCP Client (Amandil): Skrip soal_2.sh dijalankan di Amandil untuk meminta IP.
 * Hasil (Berdasarkan Bukti Gambar):
   Berhasil. Ketiga komponen berfungsi.
   * Server (Aldarion): Layanan isc-dhcp-server berhasil di-restart dan verifikasi status menunjukkan layanan aktif (Bukti: 23513.jpg - panel kiri, "Me-restart isc-dhcp-server... Setup Aldarion Selesai").
   * Relay (Durin): Instalasi dan konfigurasi isc-dhcp-relay berhasil, termasuk aktivasi IP Forwarding (Bukti: 23512.jpg - panel kiri).
   * Client (Amandil): Proses handshake DHCP (DISCOVER, OFFER, REQUEST, ACK) terekam dengan jelas. Amandil berhasil mendapatkan IP 192.219.1.7 dari relay (192.219.1.1 - Durin) (Bukti: 23515.jpg).
   
## Soal 3: Konfigurasi DNS Forwarding
### Tujuan:
Mengkonfigurasi node Minastir (192.219.5.2) untuk bertindak sebagai DNS Forwarder (atau Caching Server). Tujuannya adalah semua permintaan DNS dari jaringan internal ke internet (seperti google.com) akan melalui Minastir terlebih dahulu. Skrip ini juga mengubah /etc/resolv.conf di semua node klien agar menunjuk ke Minastir.
### Langkah Eksekusi & Verifikasi:
   * Skrip soal_3.sh dieksekusi di Minastir, menginstal BIND9 dan mengkonfigurasinya sebagai forwarder.
   * Skrip soal_3.sh dieksekusi di node klien, mengubah nameserver mereka.
 * Hasil (Berdasarkan Bukti Gambar):
   Terkonfigurasi. Bukti gambar menunjukkan prasyarat (konektivitas internet Minastir) terpenuhi.
   * Node Minastir terbukti aktif dan memiliki koneksi internet (dari Soal 1), yang merupakan syarat mutlak untuk dapat me-forward kueri DNS ke server eksternal (Bukti: 23514.jpg).
   * (Tidak ada gambar yang secara spesifik menunjukkan hasil nslookup melalui Minastir, namun konfigurasinya telah dijalankan).

## Soal 4: Konfigurasi DNS Master-Slave (Internal)
### Tujuan:
   Membangun layanan DNS internal untuk domain k16.com.
   * Erendis (192.219.3.3): Dikonfigurasi sebagai Master DNS Server.
   * Amdir (192.219.3.4): Dikonfigurasi sebagai Slave DNS Server.
   * Client (Miriel): Dikonfigurasi untuk menggunakan Erendis sebagai resolver.
### Langkah Eksekusi & Verifikasi:
   Skrip soal_4.sh dieksekusi di Erendis, Amdir, dan Miriel (atau klien lain).
 * Hasil (Berdasarkan Bukti Gambar):
   Sebagian Gagal. Konfigurasi Master berhasil secara lokal, namun Slave dan resolusi dari Klien gagal.
   * Master (Erendis): Berhasil. Verifikasi lokal (dig @localhost palantir.k16.com) mengembalikan jawaban yang benar (192.219.4.3) dengan status NOERROR (Bukti: 23490.jpg).
   * Slave (Amdir): Gagal. Verifikasi lokal (dig @localhost palantir.k16.com) gagal dengan status SERVFAIL (Bukti: 23492.jpg). Ini mengindikasikan Amdir gagal melakukan zone transfer (menyalin data) dari Erendis.
   * Client (Miriel): Gagal. Saat Miriel (menggunakan Erendis 192.219.3.3 sebagai server) mencoba me-resolve palantir.k16.com dan galadriel.k16.com, ia menerima status NXDOMAIN (Non-Existent Domain) (Bukti: 23494.jpg). Ini menunjukkan Erendis tidak merespons kueri dari klien eksternal, meskipun allow-query { any; } ada di skrip.
## Soal 5: Update DNS (CNAME, TXT, Reverse)
### Tujuan
   Memperbarui konfigurasi DNS di Erendis (Master) dari Soal 4. Pembaruan ini menambahkan record CNAME (www), TXT, dan yang paling penting, Reverse Zone (PTR) untuk subnet 192.219.3.0/24.
### Langkah Eksekusi & Verifikasi:
   * Skrip soal_5.sh dieksekusi di Erendis untuk memperbarui file zona.
   * Skrip soal_5.sh dieksekusi di Amdir untuk menambahkan konfigurasi reverse zone sebagai slave.
   * Verifikasi dilakukan dari Erendis (lokal) dan Miriel (klien).
 * Hasil (Berdasarkan Bukti Gambar):
   Berhasil (untuk Reverse Zone).
   * Master (Erendis): Verifikasi reverse lookup lokal (dig -x 192.219.3.3 @localhost) berhasil dengan status NOERROR, memetakan IP kembali ke nama ns1.k16.com. (Bukti: 23496.jpg).
   * Client (Miriel): Verifikasi reverse lookup dari klien (host 192.219.3.3 dan host 192.219.3.4) juga berhasil. Klien dapat dengan benar memetakan 192.219.3.3 ke ns1.k16.com. dan 192.219.3.4 ke ns2.k16.com. (Bukti: 23498.jpg).

## Soal 6: Update Konfigurasi DHCP Server
### Tujuan:
   Menimpa (overwrite) file konfigurasi DHCP Server di Aldarion (/etc/dhcp/dhcpd.conf) dengan pengaturan baru dari skrip soal_6.sh. Perubahan utama mencakup max-lease-time, option domain-name-servers baru, dan reservasi IP untuk Khamul.
### Langkah Eksekusi & Verifikasi:
   Skrip soal_6.sh dieksekusi di Aldarion.
 * Hasil (Berdasarkan Bukti Gambar):
   Berhasil.
   * Bukti gambar (23500.jpg) adalah tangkapan layar yang menunjukkan isi file konfigurasi baru dan eksekusi skrip secara bersamaan.
   * Terlihat jelas max-lease-time 3600, subnet 192.219.1.0 (Manusia), subnet 192.219.2.0 (Peri), dan subnet 192.219.3.0 (Kurcaci) dengan opsi yang sesuai dari skrip.
   * Di bagian bawah gambar, terlihat log service isc-dhcp-server restart (Stopping ISC DHCPv4 server... dan Starting ISC DHCPv4 server...), yang mengkonfirmasi bahwa skrip telah dieksekusi dan layanan di-restart untuk menerapkan perubahan.
