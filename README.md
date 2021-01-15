# kubernetes
A multi master cluster running a stateful application with dynamic volume provisioning

### About roles

- haproxy: provides haproxy server, a loadbalancer for kubernetes api server
- cluster: Setups Docker, Kubernetes and joins workers and masters to the cluster
- storage: Provides a nfs server and deploys an application in order to we have a dynamic volume provisioning.
- app: Contains a helm chart in which there is a stateful application with a hpa resource configured to have horizontal pod scaling.
