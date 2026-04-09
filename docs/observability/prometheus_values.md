# Prometheus Values Reference

This document explains the Prometheus metric names exported in [values.json](./values.json).

## What `values.json` contains

[`values.json`](./values.json) is a JSON payload with:

- `status`: request result from the exporter or script that produced the file
- `data`: a flat list of Prometheus metric names

This file is best treated as an inventory of available metrics. It tells you which series names exist, but it does not include:

- metric descriptions
- label names or label values
- sample values
- scrape targets
- dashboards or alert thresholds

## How to read Prometheus metric names

Prometheus names usually follow this pattern:

```text
<producer>_<domain>_<measurement>_<unit?>
```

Examples:

- `kube_pod_status_phase`
- `container_cpu_usage_seconds_total`
- `prometheus_target_scrape_duration_seconds`
- `otelcol_yuzu_jobs_processed_total`

Common suffixes in this file:

- `_total`: counter, usually increasing over time
- `_seconds`: time value in seconds
- `_bytes`: size or memory value in bytes
- `_percent`: percentage-style value
- `_ratio`: ratio between 0 and 1 in many cases
- `_bucket`, `_sum`, `_count`: histogram parts

## Metric families in this export

The metrics in [`values.json`](./values.json) come from multiple producers. The most important groups are below.

### 1. Prometheus self-monitoring

These describe Prometheus itself:

- `prometheus_*`
- `promhttp_*`
- `scrape_*`
- `up`

Typical use:

- confirm Prometheus is healthy
- inspect scrape duration and sample volume
- detect failed target discovery or ingestion issues

Examples:

- `up`
- `scrape_duration_seconds`
- `prometheus_target_scrape_duration_seconds_*`
- `prometheus_tsdb_*`

### 2. Kubernetes object state

These come from kube-state-metrics and describe cluster objects rather than raw node usage:

- `kube_*`

Typical use:

- deployments, pods, jobs, statefulsets, daemonsets
- desired versus ready replica comparisons
- object lifecycle and status tracking

Examples:

- `kube_deployment_status_replicas_available`
- `kube_pod_status_phase`
- `kube_job_status_failed`
- `kube_node_status_condition`

### 3. Kubelet and control plane metrics

These represent Kubernetes runtime and API internals:

- `kubelet_*`
- `apiserver_*`
- `workqueue_*`
- `rest_client_*`
- `controller_runtime_*`

Typical use:

- kubelet performance and pod startup timing
- API server request behavior
- controller reconcile latency and errors
- internal queue pressure

Examples:

- `kubelet_pod_start_duration_seconds_*`
- `apiserver_delegated_authn_request_total`
- `controller_runtime_reconcile_total`
- `workqueue_depth`

### 4. Container and runtime resource metrics

These are resource-level metrics for running workloads:

- `container_*`

Typical use:

- CPU throttling
- memory working set
- filesystem usage
- network traffic

Examples:

- `container_cpu_usage_seconds_total`
- `container_cpu_cfs_throttled_seconds_total`
- `container_memory_working_set_bytes`
- `container_network_receive_bytes_total`

### 5. Language and process runtime metrics

These expose application runtime internals:

- `go_*`
- `process_*`
- `nodejs_*`

Typical use:

- garbage collection and heap tracking
- goroutine or event loop pressure
- process memory and file descriptor usage

Examples:

- `go_goroutines`
- `go_gc_duration_seconds_*`
- `process_resident_memory_bytes`
- `nodejs_eventloop_lag_p99_seconds`

### 6. OpenTelemetry Collector exported metrics

These come from collectors or custom telemetry pipelines:

- `otelcol_*`

This export includes both infrastructure and application-oriented metrics. Examples visible in the file include:

- `otelcol_proxmox_*`: Proxmox node and VM metrics
- `otelcol_yuzu_*`: Yuzu job processing and Proxmox API activity

Examples:

- `otelcol_proxmox_vm_cpu_percent`
- `otelcol_proxmox_vm_mem_bytes`
- `otelcol_yuzu_active_jobs`
- `otelcol_yuzu_jobs_processed_total`

## How to interpret histogram metrics

When a metric ends with `_bucket`, `_sum`, and `_count`, it is a histogram.

Example:

- `otelcol_yuzu_job_duration_seconds_bucket`
- `otelcol_yuzu_job_duration_seconds_sum`
- `otelcol_yuzu_job_duration_seconds_count`

Use them like this:

- `_count`: total observations
- `_sum`: total accumulated value
- `_bucket`: observations grouped by upper bound label `le`

Typical PromQL for histogram quantiles:

```promql
histogram_quantile(
  0.95,
  sum by (le) (rate(otelcol_yuzu_job_duration_seconds_bucket[5m]))
)
```

## Practical ways to explore this file

Use [`values.json`](./values.json) when you want to answer questions like:

- Which metrics are available for Prometheus itself?
- Do we have pod-level or node-level metrics?
- Are there custom `otelcol_*` metrics for our services?
- Do we have histograms for latency, or only counters and gauges?

Suggested exploration flow:

1. Start with the metric family prefix such as `kube_`, `container_`, `prometheus_`, or `otelcol_`.
2. Identify the metric type from the suffix such as `_total`, `_bytes`, or histogram parts.
3. Query the metric in Prometheus or Grafana Explore.
4. Inspect labels before building dashboards or alerts.

## Example starting queries

These are useful first checks once you know the metric names exist.

**Target health**

```promql
up
```

**Container CPU usage**

```promql
sum by (pod) (rate(container_cpu_usage_seconds_total[5m]))
```

**Container memory working set**

```promql
sum by (pod) (container_memory_working_set_bytes)
```

**Pod phase count**

```promql
sum by (phase) (kube_pod_status_phase)
```

**Prometheus scrape duration**

```promql
rate(prometheus_target_scrape_duration_seconds_sum[5m])
```

**Yuzu jobs processed**

```promql
rate(otelcol_yuzu_jobs_processed_total[5m])
```

## Important limitations

Do not assume that a metric name alone tells the full story. Before creating dashboards or alerts, verify:

- labels available on the metric
- whether the metric is a counter, gauge, or histogram
- expected cardinality
- scrape interval
- whether missing data means zero, stale, or target down

## Summary

[`values.json`](./values.json) is a catalog of available Prometheus metrics across Prometheus, Kubernetes, containers, runtimes, and OpenTelemetry-exported services. Use it to discover what can be queried, then validate the metric labels and behavior in Prometheus or Grafana before turning it into dashboards or alerts.
