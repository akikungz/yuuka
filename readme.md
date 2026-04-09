# Kubernetes manifests for Cloud-Based Platform Deployment and Documentation

This repository contains Kubernetes manifests and deployment documentation for a cloud-based platform consisting of a frontend, backend, worker, database, cache, object storage, and supporting observability services. It also documents the external reverse-proxy layer used in front of the cluster.

## Deployment Overview

### Services Included
- **Frontend** [akikungz/midori](https://github.com/akikungz/midori) - A web application for user interaction.
- **Backend** [akikungz/momoi](https://github.com/akikungz/momoi) - The core application logic, API, and authentication endpoints.
- **Worker** [akikungz/yuzu](https://github.com/akikungz/yuzu) - Background job processing.
- **External Reverse Proxy Automation** [akikungz/satsuki](https://github.com/akikungz/satsuki) - Generates Nginx and SSH access configuration on the external reverse-proxy host.
- **Database** (PostgreSQL) - A relational database for storing application data.
- **Cache** (Redis) - An in-memory data structure store for caching and message brokering.
- **Object Storage** (RustFS) - An S3-compatible object storage service.

### Monitoring and Logging
- **Prometheus** - Monitoring system and time series database.
- **Grafana** - Analytics and monitoring platform.
- **Loki** - Log aggregation system.
- **Jaeger** - Distributed tracing system.
- **Promtail** - Log shipping agent for Loki.
- **Node Exporter** - Export hardware and OS metrics.
- **Kube State Metrics** - Generate metrics about the state of Kubernetes objects.
- **InfluxDB** - Time series database for storing monitoring data from Proxmox VE.

## Documentation

In progress...
