docker build -t haproxy-simple .
docker run -p 8000:8000 -p 8181:8181 -it --rm haproxy-simple
