# Kubernetes
A HA cluster running a stateful application with dynamic volume provisioning.


This cluster contains two main nodes and three worker nodes. Also a nfs server and a proxy server are there. In fact we have 7 nodes.


All things we need to run this cluster are [vagrant](https://www.vagrantup.com/) and [ansible](https://www.ansible.com/). Although we did not follow the quorum principle for number of main nodes, it could be an experimental project.


We use ansible to provision our clusters running on top of vagrant. Ansible tasks we've written to provision our cluster are packaged as [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html). If we want to describe what every role does, a summary is below. We will explain more in the following.


### About roles

- haproxy: Provides haproxy server, a load balancer for kubernetes api server.
- cluster: Setups Docker, Kubernetes and joins workers and masters to the cluster.
- storage: Provides a nfs server and deploys an application in order to we have a dynamic volume provisioning.
- metrics: Setups a metrics server in order to have metrics about nodes, pods and consumed resources such as cpu utilization.
- app: Contains a helm chart in which there is a stateful application with a hpa resource configured to have horizontal pod auto scaler.



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
Therefore, We have a task in which we monitor the heart of control plane (pods in `kube-system` namespace)

**storage role**

As mentioned We have a nfs server to store our cluster wide data. You can see the directory shared on this server.
Run `vagrant ssh storage`, and go to the shared directory: `cd /srv/nfs/kubedata` to see the data mounted to the pods which scheduled on every node in our cluster. This role setup nfs server and share the directory, (configure `/etc/exports`)

Also in this role, We have some kubernetes resources which help us to claim persistent volumes dynamically. After setting up the nfs server, We deploy all the resources to Kubernetes to let our pods claim persistent volumes when they need.


**app role**

This role consists a [helm chart](https://helm.sh/docs/topics/charts/) named `Kubab`. Kubab is a simple nodejs application and also a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) of one  which prints an id consists on it. An [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) creates that id and writes it to the persistent volume bound to it. As the persistent volume has been bound to the main pod too, It can read and show the id.
Also `Kubab` has a Service and HPA resource. The Service resource provides a route to the web application from the cluster outside. HPA resource is configured to scale the Statefulset application when its cpu load is over the threshold. The threshold is configured in `values.yaml` of the chart.    

The tasks in this role is responsible for installing [helm](https://helm.sh/) and deploying the chart to the cluster. After that, an url is printed out through which we can access the web application.

For example an application url is: `http://172.16.16.101:32119`
The port in application url may be differ from here, based on the randomly port assigned to the NodePort service.



**metrics role**

This role setups [Kubernetes metrics server](https://github.com/kubernetes-sigs/metrics-server). By the meteics sever we have a lot of metrics about our cluster resources. Thanks to the metrics provided by the server, The HPA manifest in `Kubab` helm chart can scale our application automatically.

Also, this role installs [Siege](https://github.com/JoeDog/siege) load tester. With Siege We can see how our application will be scaled if  utilization of a pod pass over a threshold.

You can enter to `kmaster1` (one of main nodes) and use Siege.

`vagrant ssh kmaster1`

`siege -c 5 -t 3m [application_url]` : (Fires five  concurrent requests that take 3 minutes)

After a few seconds, the Horizontal Pod Autoscaler which We defined in the `kubab` chart, comes and scales our application.

When the application is scaling, You can monitor the volumes created on `storage` machine simultaneously (`cd /srv/nfs/kubedata`)
Also you can run `watch kubectl get statefulset kubab` in one of main nodes to see what is happening.


### List of nodes
You can see list of nodes in `Vagrantfile` or `inventory` too. For example you can run `vagrant ssh storage` or `vagrant ssh kmaster2` to ssh to nfs server and second main node respectively.

As you can see we use 172.16.16.X ip range because `Calico` uses 192.168.0.0/16 subnet to provide its networking service.

| Node          | Role          |         IP  |
| ------------- | ------------- |-------------|
| kmaster1      | main          |172.16.16.101|
| kmaster2      | main          |172.16.16.102|
| kworker1      | worker        |172.16.16.201|
| kworker2      | worker        |172.16.16.202|
| kworker3      | worker        |172.16.16.203|
| storage       | nfs server    |172.16.16.50 |
| loadbalancer  | load balancer |172.16.16.100|


### Up and running the cluster
You can just run `vagrant up` command to run, provision and deploy the application.


### kubectl
You can ssh to one of main nodes and then switch to the `root` user to run `kubectl`:
1. `vagrant ssh kmaster1`
2. `sudo su`
3. `kubectl get po -n kube-system`

### helm
`helm` is installed on `kmaster1`
1. `vagrant ssh kmaster1`
2. `sudo su`
3. `helm list`

### Docker image
The image that the `helm` chart deploys is: [imikiani/kubab](https://hub.docker.com/r/imikiani/kubab). It's Dockerfile is under `docker-image` directory.