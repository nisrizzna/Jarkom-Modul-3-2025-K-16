#  Erendis
cat > /etc/bind/jarkom/k44.com << EOF
\$TTL    604800
@       IN      SOA     k44.com. root.k44.com. (
                        2024102802      ; Serial (increment!)
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@               IN      NS      ns1.k44.com.
@               IN      NS      ns2.k44.com.
ns1             IN      A       192.219.3.3
ns2             IN      A       192.219.3.4

; CNAME untuk www
www             IN      CNAME   k44.com.

; TXT Records
@               IN      TXT     "Cincin Sauron: elros.k44.com"
@               IN      TXT     "Aliansi Terakhir: pharazon.k44.com"

;  Records
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

cat > /etc/bind/named.conf.local << EOF
zone "k44.com" {
    type master;
    file "/etc/bind/jarkom/k44.com";
    allow-transfer { 192.219.3.4; };
};

# Reverse zone untuk Erendis (subnet 192.219.3.0/24)
zone "3.76.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/3.76.10.in-addr.arpa";
    allow-transfer { 192.219.3.4; };
};
EOF

cat > /etc/bind/jarkom/3.76.10.in-addr.arpa << EOF
\$TTL    604800
@       IN      SOA     k44.com. root.k44.com. (
                        2024102801      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      ns1.k44.com.
@       IN      NS      ns2.k44.com.

; PTR Records untuk reverse lookup
3       IN      PTR     ns1.k44.com.    ; 192.219.3.3 -> ns1.k44.com (Erendis)
4       IN      PTR     ns2.k44.com.    ; 192.219.3.4 -> ns2.k44.com (Amdir)
EOF

service named restart

#  Amdir
cat >> /etc/bind/named.conf.local << EOF
zone "3.76.10.in-addr.arpa" {
    type slave;
    file "/var/lib/bind/3.76.10.in-addr.arpa";
    masters { 192.219.3.3; };
};
EOF

service named restart

# TEST

#  Erendis
dig @localhost www.k44.com
dig @localhost k44.com TXT
dig -x 192.219.3.3 @localhost
dig -x 192.219.3.4 @localhost

#  Amdir
dig @localhost www.k44.com
dig @localhost k44.com TXT
dig -x 192.219.3.3 @localhost

#  Client
echo "nameserver 192.219.3.3" > /etc/resolv.conf
nslookup www.k44.com
dig k44.com TXT
host 192.219.3.3
host 192.219.3.4
