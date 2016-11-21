# Example of server persistence where "server" is a logical group, WIP.
#
# docker build -t foo . && docker run -it --rm -p 8080:8080 -p 8081:8081 -p 8181:8181 -e SERVER=httpbin.org:80 foo
#
# Response is RR from the persisted sub-pool of servers in "release b".
# curl -v -o /dev/null -H "Cookie: apprel=b" -sSq 0:8081/delay/0
#
# Remove cookie to fall back to RR for build selection.

FROM aasmith/haproxy

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# HAProxy *must* background and detach, otherwise nbprocs stays at 1.
# To counter this, the while loop will execute while any process
# listed in the haproxy.pid file continues to exist. Once all these
# processes have died, the loop will end and the container will exit.

CMD haproxy -f /usr/local/etc/haproxy/haproxy.cfg \
            -p /var/run/haproxy.pid \
            -sf $(pidof haproxy); \
            while kill -0 $(cat /var/run/haproxy.pid); do sleep 2; done
