FROM aasmith/haproxy:1.8.0

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY certs       /usr/local/etc/haproxy/certs

CMD haproxy -db -f /usr/local/etc/haproxy/haproxy.cfg
