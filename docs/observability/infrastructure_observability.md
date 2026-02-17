# Observability Guide (kube-state-metrics, node-exporter, promtail)

This guide explains how to analyze Kubernetes cluster health and node performance using kube-state-metrics and node-exporter, and how to explore cluster logs collected by promtail in Grafana.

## Data sources overview
- **kube-state-metrics**: Kubernetes object state (deployments, pods, nodes, HPA, jobs).
- **node-exporter**: Node-level CPU, memory, disk, and network metrics.
- **promtail + Loki**: Cluster logs with labels for namespace, pod, container, and node.

## kube-state-metrics (Prometheus)
Focus on workload health, scheduling, and controller drift.

### Recommended PromQL panels
**1) Nodes Ready**
```promql
sum(kube_node_status_condition{condition="Ready",status="true"})
```

**2) Node NotReady (by node)**
```promql
kube_node_status_condition{condition="Ready",status!="true"}
```

**3) Pods by phase (namespace)**
```promql
sum by (namespace, phase) (kube_pod_status_phase)
```

**4) Pending pods**
```promql
sum(kube_pod_status_phase{phase="Pending"})
```

**5) Deployment desired vs available**
```promql
kube_deployment_spec_replicas
```
```promql
kube_deployment_status_replicas_available
```

**6) StatefulSet desired vs ready**
```promql
kube_statefulset_replicas
```
```promql
kube_statefulset_status_replicas_ready
```

**7) DaemonSet misscheduled**
```promql
sum(kube_daemonset_status_number_misscheduled)
```

**8) Job failures (last hour)**
```promql
sum(increase(kube_job_status_failed[1h]))
```

**9) HPA saturation (current vs max)**
```promql
kube_hpa_status_current_replicas
```
```promql
kube_hpa_spec_max_replicas
```

## node-exporter (Prometheus)
Use node-exporter for capacity and saturation signals.

### Recommended PromQL panels
**1) CPU usage (per node)**
```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**2) Memory available % (per node)**
```promql
100 * (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
```

**3) Disk usage % (per node, root filesystem)**
```promql
100 - (node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|overlay"}
  / node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay"} * 100)
```

**4) Disk IO (reads/writes per second)**
```promql
sum by (instance) (rate(node_disk_reads_completed_total[5m]))
```
```promql
sum by (instance) (rate(node_disk_writes_completed_total[5m]))
```

**5) Network receive/transmit (per node)**
```promql
sum by (instance) (rate(node_network_receive_bytes_total[5m]))
```
```promql
sum by (instance) (rate(node_network_transmit_bytes_total[5m]))
```

## promtail + Loki (Logs)
Promtail enriches logs with Kubernetes labels. Typical labels include:
- `namespace`, `pod`, `container`, `node`, `app`, `job`

### Recommended LogQL queries
**1) All logs in a namespace**
```logql
{namespace="default"}
```

**2) Error logs by app**
```logql
{app="<app-name>"} |= "error"
```

**3) Logs for a specific pod**
```logql
{pod="<pod-name>"}
```

**4) Error rate over time**
```logql
sum(count_over_time({namespace="default"} |= "error" [5m]))
```

**5) Container restarts correlation (use with metrics)**
```logql
{namespace="default"} |= "Back-off" or "CrashLoopBackOff"
```

## Dashboard layout ideas
- **Cluster health**: nodes ready, pending pods, failed jobs, HPA saturation.
- **Workload health**: deployment/statefulset desired vs available, pod phases.
- **Node capacity**: CPU, memory, disk usage, IO, network.
- **Logs**: namespace log stream, error stream, and crash-loop keywords.

## Correlation tips
- Use common labels in Grafana variables: `namespace`, `node`, `pod`.
- Link pod or node panels to Explore with matching LogQL filters.
- When pods go Pending or nodes NotReady, inspect logs and node metrics together.

## Validation checklist
1. Prometheus shows `kube_state_metrics` and `node-exporter` targets as UP.
2. Grafana can query Prometheus and Loki without errors.
3. Logs show expected labels (`namespace`, `pod`, `container`).
4. Dashboards render for a namespace with active workloads.
