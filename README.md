# Kubernetes
A HA cluster running a stateful application with dynamic volume provisioning.


This cluster contains two main nodes and three worker nodes. Also a nfs server and a proxy server are there. In fact we have 7 nodes.


All things we need to run this cluster are [vagrant](https://www.vagrantup.com/) and [ansible](https://www.ansible.com/). Although we did not follow the quorum principle for number of main nodes, it could be an experimental project.


We use ansible to provision our clusters running of to op vagrant. Ansible tasks we've written to provision our cluster are packaged as [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html). If we want to describe what ever role do, a summary is bellow. We will explain more iin the following.


### About roles

- haproxy: provides haproxy server, a loadbalancer for kubernetes api server
- cluster: Setups Docker, Kubernetes and joins workers and masters to the cluster
- storage: Provides a nfs server and deploys an application in order to we have a dynamic volume provisioning.
- metrics: Setups a metrics server in order to ve have metrics about nodes, pods and consumed resources such as cpu utilization.
- app: Contains a helm chart in which there is a stateful application with a hpa resource configured to have horizontal pod scaling.


I will update the readme soon.
