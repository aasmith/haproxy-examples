FROM aasmith/haproxy

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY certs       /usr/local/etc/haproxy/certs

# HAProxy *must* background and detach, otherwise nbprocs stays at 1.
# To counter this, the while loop will execute while any process
# listed in the haproxy.pid file continues to exist. Once all these
# processes have died, the loop will end and the container will exit.

CMD haproxy -f /usr/local/etc/haproxy/haproxy.cfg \
            -p /var/run/haproxy.pid \
            -sf $(pidof haproxy); \
            while kill -0 $(cat /var/run/haproxy.pid); do sleep 2; done
