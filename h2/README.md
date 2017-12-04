An example of a http2-enabled frontend.

Run `start.sh` and connect to https://localhost:8000:

```
curl -q --http2 -sSvo /dev/null -k https://0:8000
```

You might need to install and use a curl with http2 support.

See http://localhost:8181 for stats.

The docker process does not detach so that trace data can be printed to STDERR.

