
```
wget https://github.com/martin-helmich/prometheus-nginxlog-exporter/releases/download/v1.3.0/prometheus-nginxlog-exporter

docker run -p 9090:9090 \
    -v prometheus.yml:/etc/prometheus/prometheus.yml \
    --name prometheus \
    prom/prometheus
```