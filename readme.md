# Kubernetes manifests for Cloud-Based Platform Deployment and Documentation

This repository contains Kubernetes manifests for deploying a cloud-based platform consisting of multiple services, including a frontend, backend, worker, database, cache, and object storage. Additionally, it includes monitoring and logging tools to ensure the health and performance of the deployed services.

## Deployment Overview

### Services Included
- **Frontend** [akikungz/midori](https://github.com/akikungz/midori) - A web application for user interaction.
- **Backend** [akikungz/momoi](https://github.com/akikungz/momoi) - The core application logic and API.
- **Worker** [akikungz/yuzu](https://github.com/akikungz/yuzu) - Background job processing.
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
