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
- app: Contains a helm chart in which there is a stateful application with a hpa resource configured to have horizontal pod autoscaler.



**haproxy role**

As we have two main nodes, we must provide an endpoint that other nodes send their request to that. If so, worker nodes does not concern about the responsible node. They just send ther request to one endpoint. That endpoint catch the requests and send them to one of our main nodes. In fact we have a proxy server that their backend are the main nodes.

If we had just one main node, we did not need a proxy server. We use [HAProxy](http://www.haproxy.org/) for loadbalancing and dispatching requests among main nodes. Therefore in the tasks defined in the role, we setup and config haproxy server. There is a jinja2 template we build haproxy configs based on it.

**cluster role**

We set up basic components in this role. We install and configure Docker, kubelet, kubeadm and kubectl to build our cluster. Although Docker shim is deprecated some days ago, [don't panic](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/) and keep on reading this readme :) 

First, a main node initialize the cluster by running `kubadm init` command. in this command, the master node specifies that our control plane requests must be sent to the haproxy we mentioned earlier. Output of this command is an instruction for joining other main and worker nodes. In this instruction, Also there are two commands for joining other nodes as well as other guidance. All things we must do is processing the output and extracting the join commands from it. This will be done by `join_master_member.sh` and `join_worker_member.sh` scripts for joining main and worker nodes respectively.
These scripts are executed among the configuring the cluster components in some tasks of the `cluster` role.

The cluster components are installed just on main and node and worker node. haproxy and our nfs server are not aware of the cluster and just serve a proxy and nfs service.
After configuring those components and joining worker and main nodes, we must use a [CNI](https://kubernetes.io/docs/concepts/cluster-administration/networking/) provider to handle networking in our cluster. We used [Calico](https://www.projectcalico.org/) for that.

By deploying Calico in our cluster, some pods are created, and some pods previously created, may be reconfigured. By the way there is need to wait for those control plane pods and services to be stabilized. We have a task which monitors those services and when ever they are up ad running, We continue to deploy our helm charts on the cluster. 
Therefore we have a task in which we monitor the heart of control plane (pods in `kube-system` namespace)

I will update the readme soon.
