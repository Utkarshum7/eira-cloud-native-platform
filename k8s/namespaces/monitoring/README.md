# Monitoring Stack - Backend Metrics Instrumentation

Add the following to your Node.js backend for Prometheus metrics:

## 1. Install Dependencies

```bash
npm install prom-client express-prometheus-middleware
```

## 2. Update server.js

```javascript
const express = require('express');
const prometheus = require('prom-client');
const prometheusMiddleware = require('express-prometheus-middleware');

const app = express();

// Prometheus metrics setup
prometheus.collectDefaultMetrics();

const httpRequestDurationMicroseconds = new prometheus.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 5, 15, 50, 100, 500]
});

// Add middleware
app.use(prometheusMiddleware({
  metricsPath: '/metrics',
  metricsApp: app,
  collectDefaultMetrics: true,
  requestDurationHistogramBuckets: [0.1, 5, 15, 50, 100, 500]
}));

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

## 3. Annotate for Prometheus Discovery

Add these annotations to your Kubernetes deployment:

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

## Monitoring Dashboards

### Grafana Dashboard URLs

- Kubernetes Cluster: http://grafana.example.com/d/k8s-cluster
- Application Performance: http://grafana.example.com/d/app-perf
- Database Metrics: http://grafana.example.com/d/db-metrics

### Common Queries

```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status_code=~"[45][0-9]{2}"}[5m])

# Response time (p95)
histogram_quantile(0.95, rate(http_request_duration_ms_bucket[5m]))

# Memory usage
container_memory_usage_bytes{pod!=""}

# CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Database connections
pg_stat_activity_count

# Pod restart count
increase(kube_pod_container_status_restarts_total[1h])
```

## Alert Configuration

Alerts are configured in prometheus-rules ConfigMap:
- Pod crash loops
- High memory usage (>90%)
- High CPU usage (>80%)
- PersistentVolume usage (>85%)

View alerts: Prometheus UI → Alerts → Active/Pending
