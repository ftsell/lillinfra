# Observability

The observability stack is generally split into two distinct sets of daemons:

- On the one side, the `monitoring.srv.ftsell.de` server hosts *Grafana*, *Prometheus* a *BlackBox Exporter*
  (and a local *Node Exporter*) for probing public facing infrastructure components, long term storage, displaying
  and alerting purposes.
- On the other side, another *Prometheus* instance runs inside the Kubernetes Cluster.
  This instance performs auto-discovery for metrics exposed by Kubernetes and services running in the cluster which it
  then pushes via *remote-write* to the prometheus instance running on the monitoring server.

The goals of this setup is mainly the separation of failure domains (monitoring server is hosted in Finland while the
cluster is in Germany) without having to maintain and keep in mind different Grafana and Alertmanager instances.

All alerting is configured via the GUI inside Grafana and executed by the bundled Grafana Alertmanager instance.

## Configuring Cluster Service Metrics

The in-cluster prometheus automatically scrapes metrics from **Services** and **Pods** which have been configured
via Kubernetes annotations to be scraped.
The following annotations are taken into account on each of these objects:

| Annotation                    |   Default   | Description                                                     |
|-------------------------------|:-----------:|-----------------------------------------------------------------|
| `prometheus.io/scrape`        |  `"false"`  | Must be set to `"true"` to make prometheus scrape this target   |
| `prometheus.io/port`          | *All ports* | Which port of the service should be scraped for metrics         |
| `prometheus.io/metric_path`   | `/metrics`  | At which HTTP path metrics are available on the configured port |
| `prometheus.io/scrape_scheme` |   `http`    | Can be set to `https` to make prometheus scrape using HTTPS     |
