# 192.219 Minastir
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils

cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak

cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        8.8.4.4;
        1.1.1.1;
    };

    forward only;

    allow-query { 
        192.219.0.0/16;
        localhost;
    };
    listen-on { any; };
    listen-on-v6 { none; };

    dnssec-validation auto;
    auth-nxdomain no;
    recursion yes;
    allow-recursion { 
        192.219.0.0/16;
        localhost;
    };
};
EOF

service named restart

# SEMUA 192.219 (kecuali Durin dan Minastir)
cat > /etc/resolv.conf << EOF
nameserver 192.219.5.2
nameserver 8.8.8.8
EOF

# testing
# 192.219 Minastir
service named status
cat /etc/bind/named.conf.options

netstat -tulpn | grep named
ss -tulpn | grep named

nslookup google.com
dig google.com
host google.com

tail -n 20 /var/log/syslog | grep named

# 192.219 manapun kecuali Durin dan Minastir
cat /etc/resolv.conf

nslookup google.com 192.219.5.2
dig @192.219.5.2 google.com
host google.com 192.219.5.2
ping -c 3 google.com

nslookup k44.com 192.219.5.2
dig @192.219.5.2 k44.com