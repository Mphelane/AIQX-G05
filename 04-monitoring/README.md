# Monitoring & Logging Stack

### Setup

## Start Prometheus Container
- Start prometheus and mount the config file
`docker run -d --name=prometheus -p 9090:9090 -v ./prometheus:/etc/prometheus.yaml prom/prometheus`


## Start Grafana Container
- Start Grafan and mount the config file
`docker run -d --name=grafana -p 3000:3000 -v ./grafana:/etc/grafana/provisioning grafana/grafana` 

## Start Elk Stack 
Run docker compose in Elk directory:
`docker-compose up -d`
- confirm if services are running:
`docker-compose ps`

# access at: 
- Elasticsearch: `curl http://localhost:9200`
- Kibana: `http://localhost:5601`

## Start filebeat ~ in Linux
sudo filebeat -e -c filebeat.yml

## -----

## Components
- Prometheus + Grafana for metrics
- ELK Stack for logs

## Setup

1. Start Prometheus & Grafana
2. Start ELK Stack
3. Ensure app exposes metrics on `/metrics` and logs to specified log path.

## Dashboards
- Available on Grafana port `3000`
- Logs available on Kibana port `5601`
