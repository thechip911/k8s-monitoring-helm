<!--
(NOTE: Do not edit README.md directly. It is a generated file!)
(      To make changes, please modify README.md.gotmpl and run `helm-docs`)
-->

# k8s-monitoring

![Version: 2.0.26](https://img.shields.io/badge/Version-2.0.26-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.0.26](https://img.shields.io/badge/AppVersion-2.0.26-informational?style=flat-square)

Capture all telemetry data from your Kubernetes cluster.

## Usage

### Migrating from v1

v2 introduces some significant changes to the chart configuration values. Refer to the migration [documentation](./docs/Migration.md) for tools and strategies to migrate from v1.

### Setup Grafana chart repository

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Build your values

There are some required values that will need to be used with this chart. The basic structure of the values file is:

```yaml
cluster: {} # Cluster configuration, including the cluster name

destinations: [] # List of destinations where telemetry data will be sent

# Features to enable, which determines what data to collect
clusterMetrics: {}
clusterEvents: {}
# etc...
...

# Telemetry collector definitions
alloy-metrics: {}
alloy-singleton: {}
```

Here is more detail about the different sections:

#### Cluster

This section defines the name of your cluster, which will be set as labels to all telemetry data.

```yaml
cluster:
  name: my-cluster
```

#### Destinations

([Documentation](./docs/destinations/README.md))

This section defines the destinations for your telemetry data. You can configure multiple destinations for logs,
metrics, and traces. Here are the supported destination types:

| Type         | Protocol         | Telemetry Data        | Docs                                      |
|--------------|------------------|-----------------------|-------------------------------------------|
| `prometheus` | Remote Write     | Metrics               | [Docs](./docs/destinations/prometheus.md) |
| `loki`       | Loki             | Logs                  | [Docs](./docs/destinations/loki.md)       |
| `otlp`       | OTLP or OTLPHTTP | Metrics, Logs, Traces | [Docs](./docs/destinations/otlp.md)       |
| `pyroscope`  | Pyroscope        | Profiles              | [Docs](./docs/destinations/pyroscope.md)  |

Here is an example of a destinations section:

```yaml
destinations:
  - name: hostedMetrics
    type: prometheus
    url: https://prometheus.example.com/api/prom/push
    auth:
      type: basic
      username: "my-username"
      password: "my-password"
  - name: localPrometheus
    type: prometheus
    url: http://prometheus.monitoring.svc.cluster.local:9090
  - name: hostedLogs
    type: loki
    url: https://loki.example.com/loki/api/v1/push
    auth:
      type: basic
      username: "my-username"
      password: "my-password"
      tenantIdFrom: env("LOKI_TENANT_ID")
```

#### Collectors

([Documentation](./docs/Collectors.md))

Collectors are the actual kubernetes workloads running alloy containers (deployments/statefulsets/daemonset) dedicated to certain tasks. Logs, metrics and app observability having different collection requirements leads to the need for multiple instances/clusters.

The main collectors are:

*   **alloy-logs** is the logs collector. It is deployed as a daemonset and scrapes workload logs on each node
*   **alloy-metrics** is a statefulset that scrapes metrics from prometheus sources like cadvisor and kube-state-metrics
*   **alloy-receiver** is a daemonset to collect metrics sent via HTTP, gRPC, Zipkin, etc

To enable a collector, add a new section to your values file. Ex:

```YAML
alloy-{collector_name}:
  enabled: true
```

**Specific features require specific collector configuration**. For example, the applicationObservability feature requires the alloy-receiver, with specific ports open for select protocols. Check [individual feature documentation](./docs/Features.md) to find out about collector requirements.

#### Features

([Documentation](./docs/Features.md))

This section is where you define which features you want to enable with this chart. Features define what kind of data to collect.

Here is an example of enabling some features:

```yaml
clusterMetrics:
  enabled: true

clusterEvents:
  enabled: true

podLogs:
  enabled: true
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| petewall | <pete.wall@grafana.com> |  |
| rlankfo | <robert.lankford@grafana.com> |  |

<!-- markdownlint-disable no-bare-urls -->
<!-- markdownlint-disable list-marker-space -->
## Source Code

* <https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring>
<!-- markdownlint-enable list-marker-space -->

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | annotationAutodiscovery(feature-annotation-autodiscovery) | 1.0.0 |
|  | applicationObservability(feature-application-observability) | 1.0.0 |
|  | autoInstrumentation(feature-auto-instrumentation) | 1.0.0 |
|  | clusterEvents(feature-cluster-events) | 1.0.0 |
|  | clusterMetrics(feature-cluster-metrics) | 1.0.0 |
|  | integrations(feature-integrations) | 1.0.0 |
|  | nodeLogs(feature-node-logs) | 1.0.0 |
|  | podLogs(feature-pod-logs) | 1.0.0 |
|  | profiling(feature-profiling) | 1.0.0 |
|  | prometheusOperatorObjects(feature-prometheus-operator-objects) | 1.0.0 |
| https://grafana.github.io/helm-charts | alloy-metrics(alloy) | 1.0.1 |
| https://grafana.github.io/helm-charts | alloy-singleton(alloy) | 1.0.1 |
| https://grafana.github.io/helm-charts | alloy-logs(alloy) | 1.0.1 |
| https://grafana.github.io/helm-charts | alloy-receiver(alloy) | 1.0.1 |
| https://grafana.github.io/helm-charts | alloy-profiles(alloy) | 1.0.1 |
<!-- markdownlint-enable no-bare-urls -->

## Values

### Collectors - Alloy Logs

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alloy-logs.controller.type | string | `"daemonset"` | The type of controller to use for the Alloy Logs instance. |
| alloy-logs.enabled | bool | `false` | Deploy the Alloy instance for collecting log data. |
| alloy-logs.extraConfig | string | `""` | Extra Alloy configuration to be added to the configuration file. |
| alloy-logs.liveDebugging.enabled | bool | `false` | Enable live debugging for the Alloy instance. |
| alloy-logs.logging.format | string | `"logfmt"` | Format to use for writing Alloy log lines. |
| alloy-logs.logging.level | string | `"info"` | Level at which Alloy log lines should be written. |
| alloy-logs.remoteConfig.auth.password | string | `""` | The password to use for the remote config server. |
| alloy-logs.remoteConfig.auth.passwordFrom | string | `""` | Raw config for accessing the password. |
| alloy-logs.remoteConfig.auth.passwordKey | string | `"password"` | The key for storing the username in the secret. |
| alloy-logs.remoteConfig.auth.type | string | `"none"` | The type of authentication to use for the remote config server. |
| alloy-logs.remoteConfig.auth.username | string | `""` | The username to use for the remote config server. |
| alloy-logs.remoteConfig.auth.usernameFrom | string | `""` | Raw config for accessing the username. |
| alloy-logs.remoteConfig.auth.usernameKey | string | `"username"` | The key for storing the username in the secret. |
| alloy-logs.remoteConfig.enabled | bool | `false` | Enable fetching configuration from a remote config server. |
| alloy-logs.remoteConfig.extraAttributes | object | `{}` | Attributes to be added to this collector when requesting configuration. |
| alloy-logs.remoteConfig.pollFrequency | string | `"5m"` | The frequency at which to poll the remote config server for updates. |
| alloy-logs.remoteConfig.proxyURL | string | `""` | The proxy URL to use of the remote config server. |
| alloy-logs.remoteConfig.secret.create | bool | `true` | Whether to create a secret for the remote config server. |
| alloy-logs.remoteConfig.secret.embed | bool | `false` | If true, skip secret creation and embed the credentials directly into the configuration. |
| alloy-logs.remoteConfig.secret.name | string | `""` | The name of the secret to create. |
| alloy-logs.remoteConfig.secret.namespace | string | `""` | The namespace for the secret. |
| alloy-logs.remoteConfig.url | string | `""` | The URL of the remote config server. |

### Collectors - Alloy Metrics

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alloy-metrics.controller.replicas | int | `1` | The number of replicas for the Alloy Metrics instance. |
| alloy-metrics.controller.type | string | `"statefulset"` | The type of controller to use for the Alloy Metrics instance. |
| alloy-metrics.enabled | bool | `false` | Deploy the Alloy instance for collecting metrics. |
| alloy-metrics.extraConfig | string | `""` | Extra Alloy configuration to be added to the configuration file. |
| alloy-metrics.liveDebugging.enabled | bool | `false` | Enable live debugging for the Alloy instance. |
| alloy-metrics.logging.format | string | `"logfmt"` | Format to use for writing Alloy log lines. |
| alloy-metrics.logging.level | string | `"info"` | Level at which Alloy log lines should be written. |
| alloy-metrics.remoteConfig.auth.password | string | `""` | The password to use for the remote config server. |
| alloy-metrics.remoteConfig.auth.passwordFrom | string | `""` | Raw config for accessing the password. |
| alloy-metrics.remoteConfig.auth.passwordKey | string | `"password"` | The key for storing the password in the secret. |
| alloy-metrics.remoteConfig.auth.type | string | `"none"` | The type of authentication to use for the remote config server. |
| alloy-metrics.remoteConfig.auth.username | string | `""` | The username to use for the remote config server. |
| alloy-metrics.remoteConfig.auth.usernameFrom | string | `""` | Raw config for accessing the password. |
| alloy-metrics.remoteConfig.auth.usernameKey | string | `"username"` | The key for storing the username in the secret. |
| alloy-metrics.remoteConfig.enabled | bool | `false` | Enable fetching configuration from a remote config server. |
| alloy-metrics.remoteConfig.extraAttributes | object | `{}` | Attributes to be added to this collector when requesting configuration. |
| alloy-metrics.remoteConfig.pollFrequency | string | `"5m"` | The frequency at which to poll the remote config server for updates. |
| alloy-metrics.remoteConfig.proxyURL | string | `""` | The proxy URL to use of the remote config server. |
| alloy-metrics.remoteConfig.secret.create | bool | `true` | Whether to create a secret for the remote config server. |
| alloy-metrics.remoteConfig.secret.embed | bool | `false` | If true, skip secret creation and embed the credentials directly into the configuration. |
| alloy-metrics.remoteConfig.secret.name | string | `""` | The name of the secret to create. |
| alloy-metrics.remoteConfig.secret.namespace | string | `""` | The namespace for the secret. |
| alloy-metrics.remoteConfig.url | string | `""` | The URL of the remote config server. |

### Collectors - Alloy Profiles

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alloy-profiles.controller.type | string | `"daemonset"` | The type of controller to use for the Alloy Profiles instance. |
| alloy-profiles.enabled | bool | `false` | Deploy the Alloy instance for gathering profiles. |
| alloy-profiles.extraConfig | string | `""` | Extra Alloy configuration to be added to the configuration file. |
| alloy-profiles.liveDebugging.enabled | bool | `false` | Enable live debugging for the Alloy instance. |
| alloy-profiles.logging.format | string | `"logfmt"` | Format to use for writing Alloy log lines. |
| alloy-profiles.logging.level | string | `"info"` | Level at which Alloy log lines should be written. |
| alloy-profiles.remoteConfig.auth.password | string | `""` | The password to use for the remote config server. |
| alloy-profiles.remoteConfig.auth.passwordFrom | string | `""` | Raw config for accessing the password. |
| alloy-profiles.remoteConfig.auth.passwordKey | string | `"password"` | The key for storing the password in the secret. |
| alloy-profiles.remoteConfig.auth.type | string | `"none"` | The type of authentication to use for the remote config server. |
| alloy-profiles.remoteConfig.auth.username | string | `""` | The username to use for the remote config server. |
| alloy-profiles.remoteConfig.auth.usernameFrom | string | `""` | Raw config for accessing the username. |
| alloy-profiles.remoteConfig.auth.usernameKey | string | `"username"` | The key for storing the username in the secret. |
| alloy-profiles.remoteConfig.enabled | bool | `false` | Enable fetching configuration from a remote config server. |
| alloy-profiles.remoteConfig.extraAttributes | object | `{}` | Attributes to be added to this collector when requesting configuration. |
| alloy-profiles.remoteConfig.pollFrequency | string | `"5m"` | The frequency at which to poll the remote config server for updates. |
| alloy-profiles.remoteConfig.proxyURL | string | `""` | The proxy URL to use of the remote config server. |
| alloy-profiles.remoteConfig.secret.create | bool | `true` | Whether to create a secret for the remote config server. |
| alloy-profiles.remoteConfig.secret.embed | bool | `false` | If true, skip secret creation and embed the credentials directly into the configuration. |
| alloy-profiles.remoteConfig.secret.name | string | `""` | The name of the secret to create. |
| alloy-profiles.remoteConfig.secret.namespace | string | `""` | The namespace for the secret. |
| alloy-profiles.remoteConfig.url | string | `""` | The URL of the remote config server. |

### Collectors - Alloy Receiver

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alloy-receiver.alloy.extraPorts | list | `[]` | The ports to expose for the Alloy receiver. |
| alloy-receiver.controller.type | string | `"daemonset"` | The type of controller to use for the Alloy Receiver instance. |
| alloy-receiver.enabled | bool | `false` | Deploy the Alloy instance for opening receivers to collect application data. |
| alloy-receiver.extraConfig | string | `""` | Extra Alloy configuration to be added to the configuration file. |
| alloy-receiver.extraService.enabled | bool | `false` | Create an extra service for the Alloy receiver. This service will mirror the alloy-receiver service, but its name can be customized to match existing application settings. |
| alloy-receiver.extraService.fullname | string | `""` | If set, the full name of the extra service to create. This will result in the format `<fullname>`. |
| alloy-receiver.extraService.name | string | `"alloy"` | The name of the extra service to create. This will result in the format `<release-name>-<name>`. |
| alloy-receiver.liveDebugging.enabled | bool | `false` | Enable live debugging for the Alloy instance. |
| alloy-receiver.logging.format | string | `"logfmt"` | Format to use for writing Alloy log lines. |
| alloy-receiver.logging.level | string | `"info"` | Level at which Alloy log lines should be written. |
| alloy-receiver.remoteConfig.auth.password | string | `""` | The password to use for the remote config server. |
| alloy-receiver.remoteConfig.auth.passwordFrom | string | `""` | Raw config for accessing the password. |
| alloy-receiver.remoteConfig.auth.passwordKey | string | `"password"` | The key for storing the password in the secret. |
| alloy-receiver.remoteConfig.auth.type | string | `"none"` | The type of authentication to use for the remote config server. |
| alloy-receiver.remoteConfig.auth.username | string | `""` | The username to use for the remote config server. |
| alloy-receiver.remoteConfig.auth.usernameFrom | string | `""` | Raw config for accessing the username. |
| alloy-receiver.remoteConfig.auth.usernameKey | string | `"username"` | The key for storing the username in the secret. |
| alloy-receiver.remoteConfig.enabled | bool | `false` | Enable fetching configuration from a remote config server. |
| alloy-receiver.remoteConfig.extraAttributes | object | `{}` | Attributes to be added to this collector when requesting configuration. |
| alloy-receiver.remoteConfig.pollFrequency | string | `"5m"` | The frequency at which to poll the remote config server for updates. |
| alloy-receiver.remoteConfig.proxyURL | string | `""` | The proxy URL to use of the remote config server. |
| alloy-receiver.remoteConfig.secret.create | bool | `true` | Whether to create a secret for the remote config server. |
| alloy-receiver.remoteConfig.secret.embed | bool | `false` | If true, skip secret creation and embed the credentials directly into the configuration. |
| alloy-receiver.remoteConfig.secret.name | string | `""` | The name of the secret to create. |
| alloy-receiver.remoteConfig.secret.namespace | string | `""` | The namespace for the secret. |
| alloy-receiver.remoteConfig.url | string | `""` | The URL of the remote config server. |

### Collectors - Alloy Singleton

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alloy-singleton.controller.replicas | int | `1` | The number of replicas for the Alloy Singleton instance. This should remain a single instance to avoid duplicate data. |
| alloy-singleton.controller.type | string | `"deployment"` | The type of controller to use for the Alloy Singleton instance. |
| alloy-singleton.enabled | bool | `false` | Deploy the Alloy instance for data sources required to be deployed on a single replica. |
| alloy-singleton.extraConfig | string | `""` | Extra Alloy configuration to be added to the configuration file. |
| alloy-singleton.liveDebugging.enabled | bool | `false` | Enable live debugging for the Alloy instance. |
| alloy-singleton.logging.format | string | `"logfmt"` | Format to use for writing Alloy log lines. |
| alloy-singleton.logging.level | string | `"info"` | Level at which Alloy log lines should be written. |
| alloy-singleton.remoteConfig.auth.password | string | `""` | The password to use for the remote config server. |
| alloy-singleton.remoteConfig.auth.passwordFrom | string | `""` | Raw config for accessing the password. |
| alloy-singleton.remoteConfig.auth.passwordKey | string | `"password"` | The key for storing the password in the secret. |
| alloy-singleton.remoteConfig.auth.type | string | `"none"` | The type of authentication to use for the remote config server. |
| alloy-singleton.remoteConfig.auth.username | string | `""` | The username to use for the remote config server. |
| alloy-singleton.remoteConfig.auth.usernameFrom | string | `""` | Raw config for accessing the username. |
| alloy-singleton.remoteConfig.auth.usernameKey | string | `"username"` | The key for storing the username in the secret. |
| alloy-singleton.remoteConfig.enabled | bool | `false` | Enable fetching configuration from a remote config server. |
| alloy-singleton.remoteConfig.extraAttributes | object | `{}` | Attributes to be added to this collector when requesting configuration. |
| alloy-singleton.remoteConfig.pollFrequency | string | `"5m"` | The frequency at which to poll the remote config server for updates. |
| alloy-singleton.remoteConfig.proxyURL | string | `""` | The proxy URL to use of the remote config server. |
| alloy-singleton.remoteConfig.secret.create | bool | `true` | Whether to create a secret for the remote config server. |
| alloy-singleton.remoteConfig.secret.embed | bool | `false` | If true, skip secret creation and embed the credentials directly into the configuration. |
| alloy-singleton.remoteConfig.secret.name | string | `""` | The name of the secret to create. |
| alloy-singleton.remoteConfig.secret.namespace | string | `""` | The namespace for the secret. |
| alloy-singleton.remoteConfig.url | string | `""` | The URL of the remote config server. |

### Features - Annotation Autodiscovery

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotationAutodiscovery | object | Disabled | Annotation Autodiscovery enables gathering metrics from Kubernetes Pods and Services discovered by special annotations. Requires a destination that supports metrics. To see the valid options, please see the [Annotation Autodiscovery feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-annotation-autodiscovery). |
| annotationAutodiscovery.destinations | list | `[]` | The destinations where cluster metrics will be sent. If empty, all metrics-capable destinations will be used. |
| annotationAutodiscovery.enabled | bool | `false` | Enable gathering metrics from Kubernetes Pods and Services discovered by special annotations. |

### Features - Application Observability

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| applicationObservability | object | Disabled | Application Observability. Requires destinations that supports metrics, logs, and traces. To see the valid options, please see the [Application Observability feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-application-observability). |
| applicationObservability.destinations | list | `[]` | The destinations where application data will be sent. If empty, all capable destinations will be used. |
| applicationObservability.enabled | bool | `false` | Enable receiving Application Observability. |
| applicationObservability.receivers | object | `{}` | The receivers used for receiving application data. |

### Features - Auto-Instrumentation

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoInstrumentation | object | Disabled | Auto-Instrumentation. Requires destinations that supports metrics, logs, and traces. To see the valid options, please see the [Auto-Instrumentation feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-auto-instrumentation). |
| autoInstrumentation.destinations | list | `[]` | The destinations where application data will be sent. If empty, all capable destinations will be used. |
| autoInstrumentation.enabled | bool | `false` | Enable automatic instrumentation for applications. |

### Cluster

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cluster.name | string | `""` | The name for this cluster. |

### Features - Cluster Events

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterEvents | object | Disabled | Cluster events. Requires a destination that supports logs. To see the valid options, please see the [Cluster Events feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-cluster-events). |
| clusterEvents.destinations | list | `[]` | The destinations where cluster events will be sent. If empty, all logs-capable destinations will be used. |
| clusterEvents.enabled | bool | `false` | Enable gathering Kubernetes Cluster events. |

### Features - Cluster Metrics

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterMetrics | object | Disabled | Cluster Monitoring enables observability and monitoring for your Kubernetes Cluster itself. Requires a destination that supports metrics. To see the valid options, please see the [Cluster Monitoring feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-cluster-metrics). |
| clusterMetrics.destinations | list | `[]` | The destinations where cluster metrics will be sent. If empty, all metrics-capable destinations will be used. |
| clusterMetrics.enabled | bool | `false` | Enable gathering Kubernetes Cluster metrics. |

### Destinations

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| destinations | list | `[]` | The list of destinations where telemetry data will be sent. See the [destinations documentation](https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/docs/destinations/README.md) for more information. |

### Global Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.alloyModules.branch | string | `"main"` | If using git, the branch of the git repository to use. |
| global.alloyModules.source | string | `"configMap"` | The source of the Alloy modules. The valid options are "configMap" or "git" |
| global.kubernetesAPIService | string | `""` | The Kubernetes service. Change this if your cluster DNS is configured differently than the default. |
| global.maxCacheSize | int | `100000` | Sets the max_cache_size for every prometheus.relabel component. ([docs](https://grafana.com/docs/alloy/latest/reference/components/prometheus/prometheus.relabel/#arguments)) This should be at least 2x-5x your largest scrape target or samples appended rate. |
| global.platform | string | `""` | The specific platform for this cluster. Will enable compatibility for some platforms. Supported options: (empty) or "openshift". |
| global.scrapeInterval | string | `"60s"` | How frequently to scrape metrics. |

### Features - Service Integrations

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| integrations | object | No integrations enabled | Service Integrations enables gathering telemetry data for common services and applications deployed to Kubernetes. To see the valid options, please see the [Service Integrations documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-integrations). |
| integrations.destinations | list | `[]` | The destinations where integration metrics will be sent. If empty, all metrics-capable destinations will be used. |

### Features - Node Logs

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nodeLogs | object | Disabled | Node logs. Requires a destination that supports logs. To see the valid options, please see the [Node Logs feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-node-logs). |
| nodeLogs.destinations | list | `[]` | The destinations where logs will be sent. If empty, all logs-capable destinations will be used. |
| nodeLogs.enabled | bool | `false` | Enable gathering Kubernetes Cluster Node logs. |

### Features - Pod Logs

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| podLogs | object | Disabled | Pod logs. Requires a destination that supports logs. To see the valid options, please see the [Pod Logs feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-pod-logs). |
| podLogs.destinations | list | `[]` | The destinations where logs will be sent. If empty, all logs-capable destinations will be used. |
| podLogs.enabled | bool | `false` | Enable gathering Kubernetes Pod logs. |

### Features - Profiling

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| profiling | object | Disabled | Profiling enables gathering profiles from applications. Requires a destination that supports profiles. To see the valid options, please see the [Profiling feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-profiling). |
| profiling.destinations | list | `[]` | The destinations where profiles will be sent. If empty, all profiles-capable destinations will be used. |
| profiling.enabled | bool | `false` | Enable gathering profiles from applications. |

### Features - Prometheus Operator Objects

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| prometheusOperatorObjects | object | Disabled | Prometheus Operator Objects enables the gathering of metrics from objects like Probes, PodMonitors, and ServiceMonitors. Requires a destination that supports metrics. To see the valid options, please see the [Prometheus Operator Objects feature documentation](https://github.com/grafana/k8s-monitoring-helm/tree/main/charts/k8s-monitoring/charts/feature-prometheus-operator-objects). |
| prometheusOperatorObjects.destinations | list | `[]` | The destinations where metrics will be sent. If empty, all metrics-capable destinations will be used. |
| prometheusOperatorObjects.enabled | bool | `false` | Enable gathering metrics from Prometheus Operator Objects. |

### Features - Self-reporting

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| selfReporting.destinations | list | `[]` | The destinations where self-report metrics will be sent. If empty, all metrics-capable destinations will be used. |
| selfReporting.enabled | bool | `true` | Enable Self-reporting. |
| selfReporting.scrapeInterval | string | 60s | How frequently to generate self-report metrics. This does utilize the global scrapeInterval setting. |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraObjects | list | `[]` | Deploy additional manifest objects |
