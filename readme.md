# Testing

This relies on installing a few tools:
1. [helm 3.17.3](https://github.com/helm/helm/releases/tag/v3.17.3)
2. [helm-ct 3.11.0](https://github.com/helm/chart-testing/releases/tag/v3.11.0)
3. [helm-unittest 0.8.2](https://github.com/helm-unittest/helm-unittest/releases/tag/v0.8.2)

You can use asdf/mise to install helm and helm-ct, then use helm itself to install helm unittest.

After installing all these tools, you can run:

    ct lint --all 

Alternately, you can test using docker:

    docker build . -t coolkit:dev && docker run -v `realpath .`:/src coolkit:dev ct lint --all 

# Notes
1. It wasn't clear if "SHA tags" meant "tags that were commit shas" or "tags 
   that were pinned to a sha", so I supported both.
2. It wasn't clear what "communicate with each other" meant, but a Service 
   should support both scenarios:
   1. They need to communicate individually with each other by Pod IP address 
      and know how many pods there are in total. If they're aware of kubernetes, 
      they can query EndpointSlices and get the list of IP addresses
   2. They need to communicate with the cluster of pods as a whole, and simply
      need a network endpoint that load balances or round-robin's requests.
3. I assumed that the /metrics endpoint exposed metrics of the cluster, rather
   individual pods. If we need metrics for each pod, we'd swap the 
   ServiceMonitor for a PodMonitor.
4. I assumed that the /healthz endpoint was suitable for probes.
5. There wasn't quite enough information to fill out the keda autoscaler, so I 
   invented values for valueLocation and targetValue.
6. There were a few options for connection to cloudsql; I opted to implement
   a cloudsql proxy using serviceaccount auth, as it seemed like the most secure
   and required the least maintenance (with regardes to rotating credentials).

Monitoring TODO:
- create prometheus rules for monitoring:
  - memory
  - cpu
  - OOM events
  - max scaleup events
  - performance (latency, processing time, etc)
- lint / test charts via [helm-ct](https://github.com/helm/chart-testing)
- auto release new charts via [helm-cr](https://github.com/helm/chart-releaser)

Scaling to multi cluster:
1. create an argocd appset that targets this chart
2. create helm chart values files that overlay per-cluster changes

Something like the following (note: this is not a fully valid applicationset, 
I'm only showing the interesting parts):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: coolkit
spec:
  generator:
    # assume that clusters have a label that we can use
    - clusters:
        selector:
          matchLabels:
            environment: production
  goTemplate: true
  template:
    metadata:
      name: '{{ .metadata.labels.cluster_id }}-coolkit'
    spec:
      source:
        helm:
          # this lets us scale/monitor/resource according to cluster or 
          # environment without requiring that we copy/paste all configuration
          ignoreMissingValueFiles: true
          valueFiles:
            - values.yaml
            - values-production.yaml
            - values-{{ .metadata.labels.cluster_id }}.yaml
      destination:
        server: '{{ .server }}'
```
