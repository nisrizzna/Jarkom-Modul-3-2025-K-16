# Node Erendis
apt-get install -y bind9

cat > /etc/bind/named.conf.local << EOF
zone "k16.com" {
    type master;
    file "/etc/bind/jarkom/k16.com";
    allow-transfer { 192.219.3.4; };
};
EOF

mkdir -p /etc/bind/jarkom

cat > /etc/bind/jarkom/k16.com << EOF
\$TTL    604800
@       IN      SOA     k16.com. root.k16.com. (
                        2024102801      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@               IN      NS      ns1.k16.com.
@               IN      NS      ns2.k16.com.
ns1             IN      A       192.219.3.3
ns2             IN      A       192.219.3.4

; Node Records
palantir        IN      A       192.219.4.3
narvi           IN      A       192.219.4.4
elros           IN      A       192.219.1.7
pharazon        IN      A       192.219.2.4
elendil         IN      A       192.219.1.2
isildur         IN      A       192.219.1.3
anarion         IN      A       192.219.1.4
galadriel       IN      A       192.219.2.5
celeborn        IN      A       192.219.2.6
oropher         IN      A       192.219.2.7
EOF

cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

service named restart

# Node Amdir
apt-get install -y bind9

cat > /etc/bind/named.conf.local << EOF
zone "k16.com" {
    type slave;
    file "/var/lib/bind/k16.com";
    masters { 192.219.3.3; };
};
EOF

cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

service named restart

# TEST

# Node Erendis (master)
service named status
named-checkconf
named-checkzone k16.com /etc/bind/jarkom/k16.com
rndc status

dig @localhost k16.com
dig @localhost palantir.k16.com
dig @localhost elros.k16.com

tail -f /var/log/syslog | grep named

# Node Amdir (slave)
service named status
ls -la /var/lib/bind/
dig @localhost palantir.k16.com

#  Node Client (Miriel, Celebrimbor)
echo "nameserver 192.219.3.3" > /etc/resolv.conf

nslookup palantir.k16.com
nslookup elros.k16.com
nslookup pharazon.k16.com
nslookup elendil.k16.com
nslookup isildur.k16.com
nslookup anarion.k16.com
nslookup galadriel.k16.com
nslookup celeborn.k16.com
nslookup oropher.k16.com

dig k16.com NS

echo "nameserver 192.219.3.4" > /etc/resolv.conf
nslookup palantir.k16.com