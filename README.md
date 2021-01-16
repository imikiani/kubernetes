# kubernetes
A multi master cluster running a stateful application with dynamic volume provisioning

### About roles

- haproxy: provides haproxy server, a loadbalancer for kubernetes api server
- cluster: Setups Docker, Kubernetes and joins workers and masters to the cluster
- storage: Provides a nfs server and deploys an application in order to we have a dynamic volume provisioning.
- metrics: Setups a metrics server in order to ve have metrics about nodes, pods and consumed resources such as cpu utilization.
- app: Contains a helm chart in which there is a stateful application with a hpa resource configured to have horizontal pod scaling.


I will update the readme soon.
