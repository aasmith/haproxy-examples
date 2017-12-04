An example of a http2-enabled frontend.

Run `start.sh` and connect to https://localhost:8000:

```
curl -q --http2 -sSvo /dev/null -k https://0:8000
```

You might need to install and use a curl with http2 support.

See http://localhost:8181 for stats.

The docker process does not detach so that trace data can be printed to STDERR.


### Example Request-Response

```
$ curl -q --http2 -sSvo /dev/null -k https://0:8000
* Rebuilt URL to: https://0:8000/
*   Trying 0.0.0.0...
* TCP_NODELAY set
* Connected to 0 (127.0.0.1) port 8000 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: /usr/local/etc/openssl/cert.pem
  CApath: /usr/local/etc/openssl/certs
* TLSv1.2 (OUT), TLS header, Certificate Status (22):
} [5 bytes data]
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
} [512 bytes data]
* TLSv1.2 (IN), TLS handshake, Server hello (2):
{ [102 bytes data]
* TLSv1.2 (IN), TLS handshake, Certificate (11):
{ [788 bytes data]
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
{ [333 bytes data]
* TLSv1.2 (IN), TLS handshake, Server finished (14):
{ [4 bytes data]
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
} [70 bytes data]
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):
} [1 bytes data]
* TLSv1.2 (OUT), TLS handshake, Finished (20):
} [16 bytes data]
* TLSv1.2 (IN), TLS change cipher, Client hello (1):
{ [1 bytes data]
* TLSv1.2 (IN), TLS handshake, Finished (20):
{ [16 bytes data]
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN, server accepted to use h2
* Server certificate:
*  subject: C=US; ST=Some-State; O=Internet Widgits Pty Ltd
*  start date: Mar  6 22:57:00 2016 GMT
*  expire date: Mar  6 22:57:00 2017 GMT
*  issuer: C=US; ST=Some-State; O=Internet Widgits Pty Ltd
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
} [5 bytes data]
* Using Stream ID: 1 (easy handle 0x7fd599804c00)
} [5 bytes data]
> GET / HTTP/2
> Host: 0:8000
> User-Agent: curl/7.57.0
> Accept: */*
> 
{ [5 bytes data]
* Connection state changed (MAX_CONCURRENT_STREAMS updated)!
} [5 bytes data]
< HTTP/2 200 
< server: meinheld/0.6.1
< date: Mon, 04 Dec 2017 03:54:24 GMT
< content-type: text/html; charset=utf-8
< content-length: 13011
< access-control-allow-origin: *
< access-control-allow-credentials: true
< x-powered-by: Flask
< x-processed-time: 0.00875687599182
< via: 1.1 vegur
< 
{ [1136 bytes data]
* Connection #0 to host 0 left intact
```
