
# haproxy-examples

This repo contains a few examples of haproxy usage that are lesser-known. To try them
out, see [`start.sh`](start.sh) and [`haproxy.cfg`](haproxy.cfg).

They have been tested on a machine running CentOS 7.2, and Docker 1.10.2.


## "Soft-stop" between containers

This example is more a docker proof-of-concept around using a very well-known haproxy
feature; zero-downtime deployments and extending it to containers. This explores
signal-passing between other containers running haproxy.

Thanks to `SO_REUSEPORT`, haproxy can bind multiple processes to a single port. The
kernel then load balances traffic on the port across all bound processes. This
mechanism allows a "soft-stop", where a new instance of haproxy can bind to the same
ports, start accepting traffic, and then send signals to the old haproxy instance(s)
to terminate gracefully. The first signal, `SIGTTOU` will tell the old instance(s) to
stop accepting new connections, essentially relinquishing the port. The second signal,
`SIGUSR1` tells the instance(s) to process what is left in the current sessions and
then exit.

The main "concept" here is allowing a newly-created container running haproxy to send
those signals to haproxies in other containers. This can be addressed by giving the
container in question a full view of the host's PID namespace, using `--pid=host` at
run time.

Obviously, this is only going to be useful in *controlled deployments*, and not shared
environments, where access to other containers and processes would be undesirable.

Example command using soft-stop "zero-downtime" haproxy deployment across containers:

```sh
docker run --net=host --pid=host \
           -v /some/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
           -d --name haproxy.your.build.number \
           -e HAPROXY_PIDS="$(pidof haproxy)" \
           aasmith/haproxy
```

Certain bits were removed for brevity, see start.sh for the full thing.

 * `net=host` gives access to the host's network stack. This is a good idea in order
   to avoid the almost catastrophic overhead of conntrack and NAT. In this example,
   this allows the well-known ports (80, 443) to bound to by both haproxy instances
   as they cut over.

 * `pid=host` gives access to the host's PID list. This option is also useful for
   containers taking on a system monitoring role.

 * `--privileged` *isn't required*, [so there's that][0].

 * `-e HAPROXY_PIDS` passes all running haproxy instance PIDs into the running
   container, ultimately to be passed to `haproxy -sf <pids>*`. If less control is
   desired, then this could become `$(pidof haproxy)` in the image's CMD.

[0]: http://developers.redhat.com/blog/2014/11/06/introducing-a-super-privileged-container-concept/

The relevant piece of the Dockerfile:

```Dockerfile
CMD haproxy -f /usr/local/etc/haproxy/haproxy.cfg \
            -p /var/run/haproxy.pid \
            -sf ${HAPROXY_PIDS}; \
            while kill -0 $(cat /var/run/haproxy.pid); do sleep 2; done
```

As mentioned above, a variant that doesn't require PIDs to be passed in would be:

```Dockerfile
CMD haproxy -f /usr/local/etc/haproxy/haproxy.cfg \
            -p /var/run/haproxy.pid \
            -sf $(pidof haproxy); \
            while kill -0 $(cat /var/run/haproxy.pid); do sleep 2; done
```

The `kill -0` line essentially checks that any of the listed processes are running. It
does not send a signal, but performs error checking, per `kill(1)`. When no processes
are left, `kill` will return 1, thus ending the loop, and the container.

The `-sf` switch tells haproxy to send the soft-shutdown signals as dicussed above,
once the new process is in a runnable state.

## Offloading CPU-intensive workloads

Typically, haproxy spends most of its time in the kernel, and much lesser time in
user space. The largest items that tend to increase user space load are SSL and gzip.

Moving this workload to another CPU core is possible with haproxy by creating dedicated
listeners that specialize in only SSL and/or compression. The listeners can then be
connected using UNIX sockets and the PROXY protocol, created by Willy Tarreau.

An example listener that accepts port 80 traffic, compresses if possible, then passes
it onto the "regular" application frontend:

```
global
  nbproc 2
  cpu-map 1 0
  cpu-map 2 1

defaults
  bind-process 1

listen comp
  bind :80
  compression algo gzip
  server app0 /var/run/haproxy-app0.sock send-proxy-v2
  bind-process 2

frontend app
  # previously, this line would have been "bind :80"
  bind /var/run/haproxy-app0.sock accept-proxy

  # rest of the application goes here
  # ...
```

The `nbproc/cpu-map/bind-process` commands ensure that the SSL backend is pushed to
another CPU. By putting `bind-process 1` in defaults ensures all other sections stay
on the same CPU, as breaking these up becomes detrimental due to the lack of
data-sharing, such as health checks, stick-tables, etc.

It is also worthwhile creating a new stats listener for the compressor. For an
example of this, see the haproxy.cfg in this repo.

The provided haproxy.cfg also has an example of the same pattern for SSL offloading.

## Environment Interpolation

Since 1.6, haproxy can interpolate environment variables into almost anywhere in the
configuration file. The example haproxy.cfg in this repo allows the user to specify
a custom backend server, as well as a custom string to appear on the stats page.

## Other Bits

### Certs

The demo certificates were created with openssl:

```sh
openssl req -new -newkey rsa:2048 -nodes -sha256 -keyout server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
cat server.crt server.key > server.pem
```

