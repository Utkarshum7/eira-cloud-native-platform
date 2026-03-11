# Monitoring & Observability

## Overview
We utilize **Prometheus** for metrics collection and **Grafana** for dashboarding and visualization within the Kubernetes cluster.

## Stack Components
- **Prometheus**: Scrapes metrics from our frontend, backend, and PostgreSQL exporter.
- **Grafana**: Visualizes the Prometheus metrics on custom dashboards.

## Installation
The monitoring stack configuration is stored in the `k8s/` and `helm/` (if defined) directories.

To apply basic manifests:
```bash
# Note: In production you would use prometheus-community helm charts
kubectl apply -f gitops/prometheus.yaml
kubectl apply -f gitops/grafana.yaml
```

## Accessing Grafana
To access the Grafana dashboard locally from your cluster:
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
Then navigate to `http://localhost:3000` in your browser. Default login is usually `admin/admin` (change immediately in production).

## Key Metrics to Monitor
1. **Node.js Process Metrics**: Memory consumption, Event Loop Lag, Request Rates.
2. **PostgreSQL**: Connection counts, Cache Hit ratio, Database size.
3. **EKS Cluster Health**: Node CPU/Memory pressure, Pod Restarts.

## Viewing Logs
To view standard output application logs across the cluster, you can use `kubectl logs`:

```bash
# View all backend pod logs
kubectl logs -l app=backend -n eira-app -f

# View frontend pod logs
kubectl logs -l app=frontend -n eira-app -f
```
*(Consider integrating FluentBit + OpenSearch/Elasticsearch for persistent log aggregation).*
