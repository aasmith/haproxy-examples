An example of server-template usage for service discovery using SRV records.

Run `start.sh` and connect to http://localhost:8000.

See http://localhost:8181 for stats.

The docker process does not detach so that trace data can be printed to STDERR.

### TODO

 * The servers seem to list themselves as backups.
 * It would be nice to not provide a fixed number/range and just use all returned SRVs.

### See Also

 * https://www.haproxy.com/blog/dns-service-discovery-haproxy/
 * https://www.haproxy.com/blog/whats-new-haproxy-1-8/
 * https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#server-template
