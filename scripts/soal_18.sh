# ==========================================================
# == Script Gabungan Setup Replikasi MariaDB (Master-Slave) ==
# ==                                                      ==
# == Script ini mendeteksi hostname dan menjalankan:      ==
# == 1. Setup Master (Master) jika di 'Palantir'          ==
# == 2. Setup Slave (Slave) jika di 'Narvi'               ==
# ==========================================================

# Ambil nama host saat ini
CURRENT_HOST=$(hostname)
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

# Mulai logika berdasarkan nama host
case $CURRENT_HOST in

    # =================================================
    # === KASUS 1: NODE MASTER (PALANTIR)           ===
    # =================================================
    "Palantir")
        echo "--- Menjalankan setup MASTER di Palantir ---"

        # 1. Instalasi MariaDB
        apt update -y
        apt install -y mariadb-server
        service mariadb start

        # 2. Konfigurasi User & Hak Akses
        echo "Mengkonfigurasi user database..."
        mysql -u root <<EOF
-- Grant privilege untuk user laravel (diasumsikan database sudah ada)
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel'@'%';

-- Buat user replikasi baru untuk Narvi (192.219.4.4)
CREATE USER IF NOT EXISTS 'repluser'@'192.219.4.4' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'192.219.4.4';
FLUSH PRIVILEGES;
EOF

        # 3. Konfigurasi 50-server.cnf
        echo "Mengkonfigurasi $CONFIG_FILE untuk Master..."
        # Ubah bind-address
        sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/g' $CONFIG_FILE

        # Tambahkan konfigurasi Master (hanya jika belum ada)
        grep -qxF "server-id = 1" $CONFIG_FILE || \
            sed -i "/\[mysqld\]/a server-id = 1" $CONFIG_FILE
        
        grep -qxF "log_bin = /var/log/mysql/mysql-bin.log" $CONFIG_FILE || \
            sed -i "/\[mysqld\]/a log_bin = /var/log/mysql/mysql-bin.log" $CONFIG_FILE
            
        grep -qxF "binlog_do_db = laravel_db" $CONFIG_FILE || \
            sed -i "/\[mysqld\]/a binlog_do_db = laravel_db" $CONFIG_FILE

        # 4. Restart MariaDB
        echo "Me-restart MariaDB..."
        service mariadb restart

        echo "--- Setup Master di Palantir SELESAI ---"
        echo ""
        echo "--- Menjalankan Verifikasi Master (Membuat Data) ---"
        
        # 5. Verifikasi: Buat tabel dan data
        mysql -u root <<EOF
USE laravel_db;

CREATE TABLE IF NOT EXISTS elf_army (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    rank VARCHAR(30)
);

-- Kosongkan tabel agar tes bisa diulang
TRUNCATE TABLE elf_army;

INSERT INTO elf_army (name, rank)
VALUES ('Legolas', 'Archer'),
       ('Thranduil', 'King');
       
SELECT * FROM elf_army;
EOF
        echo "--- Data Verifikasi di Palantir Dibuat. ---"
        ;;

    # =================================================
    # === KASUS 2: NODE SLAVE (NARVI)               ===
    # =================================================
    "Narvi")
        echo "--- Menjalankan setup SLAVE di Narvi ---"

        # 1. Instalasi MariaDB
        apt update -y
        apt install -y mariadb-server
        service mariadb start

        # 2. Konfigurasi 50-server.cnf
        echo "Mengkonfigurasi $CONFIG_FILE untuk Slave..."
        # Ubah bind-address
        sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/g' $CONFIG_FILE

        # Tambahkan konfigurasi Slave (hanya jika belum ada)
        grep -qxF "server-id = 2" $CONFIG_FILE || \
            sed -i "/\[mysqld\]/a server-id = 2" $CONFIG_FILE
            
        grep -qxF "relay_log = /var/log/mysql/mysql-relay-bin.log" $CONFIG_FILE || \
            sed -i "/\[mysqld\]/a relay_log = /var/log/mysql/mysql-relay-bin.log" $CONFIG_FILE
            
        grep -qxF "log_bin = /var/log/mysql/mysql-bin.log" $CONFIG_FILE || \
            sed -i "/\[mysqld\]/a log_bin = /var/log/mysql/mysql-bin.log" $CONFIG_FILE

        # 3. Restart MariaDB
        echo "Me-restart MariaDB..."
        service mariadb restart

        # 4. Mengambil Status Master dari Palantir
        echo "Menunggu Palantir (Master) siap... (10 detik)"
        sleep 10
        
        echo "Mengambil status Master dari Palantir (192.219.4.3)..."
        # 2>/dev/null menyembunyikan warning password
        MASTER_INFO=$(mysql -h 192.219.4.3 -u repluser -preplpass -e "SHOW MASTER STATUS\G" 2>/dev/null)

        if [ -z "$MASTER_INFO" ]; then
            echo "GAGAL: Tidak bisa terhubung ke Palantir (192.219.4.3)."
            echo "Pastikan Palantir selesai di-setup dan user 'repluser' ada."
            exit 1
        fi

        # 5. Parsing Log File dan Posisi
        LOG_FILE=$(echo "$MASTER_INFO" | grep 'File:' | awk '{print $2}')
        LOG_POS=$(echo "$MASTER_INFO" | grep 'Position:' | awk '{print $2}')

        if [ -z "$LOG_FILE" ] || [ -z "$LOG_POS" ]; then
            echo "GAGAL: Tidak bisa parse status Master dari Palantir."
            echo "Output diterima: $MASTER_INFO"
            exit 1
        fi

        echo "Status Master Diterima: File = $LOG_FILE, Posisi = $LOG_POS"

        # 6. Konfigurasi Narvi sebagai Slave
        echo "Mengkonfigurasi Narvi sebagai Slave..."
        # Menggunakan "EOF" (tanpa kutip) agar $LOG_FILE dan $LOG_POS terbaca
        mysql -u root <<EOF
STOP SLAVE;
RESET SLAVE ALL;

CHANGE MASTER TO
    MASTER_HOST='192.219.4.3',
    MASTER_USER='repluser',
    MASTER_PASSWORD='replpass',
    MASTER_LOG_FILE='$LOG_FILE',
    MASTER_LOG_POS=$LOG_POS;

START SLAVE;
EOF

        echo "--- Setup Slave di Narvi SELESAI ---"
        echo ""
        echo "--- Menjalankan Verifikasi Slave (Membaca Data) ---"
        echo "Menunggu replikasi... (5 detik)"
        sleep 5

        # 7. Verifikasi: Cek data dan status
        mysql -u root <<EOF
USE laravel_db;

SHOW TABLES;

SELECT * FROM elf_army;

SHOW SLAVE STATUS\G
EOF
        echo "--- Verifikasi Narvi Selesai. ---"
        ;;

    # =================================================
    # === KASUS 3: HOSTNAME TIDAK DIKENALI          ===
    # =================================================
    *)
        echo "Hostname '$CURRENT_HOST' tidak dikenali."
        echo "Script ini hanya untuk node: Palantir atau Narvi."
        exit 1
        ;;
esac