FROM aasmith/haproxy:1.8.0

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

CMD haproxy -db -f /usr/local/etc/haproxy/haproxy.cfg
