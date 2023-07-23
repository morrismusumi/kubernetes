Kubernetes setup with Kubespray
==================

Prerequisites
------------
Login to the jump-server and create the project directory
```sh
$ ssh root@JUMP-SERVER-IP

$ mkdir kube-setup && cd kube-setup
```

Clone the kubespray repository and install Ansible
```sh
$ git clone https://github.com/kubernetes-sigs/kubespray.git

$ VENVDIR=kubespray-venv
$ KUBESPRAYDIR=kubespray
$ python3 -m venv $VENVDIR
$ source $VENVDIR/bin/activate
$ cd $KUBESPRAYDIR
$ pip install -U -r requirements.txt
$ cd ..
```
Preparing the necessary files
------------

Create the cluster configuration directory
```sh
$ mkdir -p clusters/eu-central
```

Generate the inventory file. 
```sh
$ declare -a IPS=(172.16.0.101 172.16.0.102 172.16.0.103)
$ CONFIG_FILE=clusters/eu-central/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}

# Edit the hosts.yaml file and match the name of the nodes to the server names in hetzner
$ vi clusters/eu-central/hosts.yaml
```

Create the cluster custom configuration file with the contents below
```sh
$ vi clusters/eu-central/cluster-config.yaml

# Custom cofiguration options for hcloud as a cloud provider
$ cat clusters/eu-central/cluster-config.yaml

cloud_provider: external
external_cloud_provider: hcloud

external_hcloud_cloud:
  token_secret_name: hcloud-api-token
  with_networks: true
  service_account_name: hcloud-sa
  hcloud_api_token: <api-token>
  controller_image_tag: v1.16.0

kube_network_plugin: cilium
network_id: kubernetes-node-network
```
Deploying the Cluster
------------

Deploy a new kubernetes cluster
```sh
$ cd kubespray
$ ansible-playbook -i ../clusters/eu-central/hosts.yaml -e @../clusters/eu-central/cluster-config.yaml --become --become-user=root cluster.yml
```

Connecting to the Cluster
------------

Install kubectl. 
```sh
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ chmod +x kubectl
$ mv kubectl /usr/local/bin
```

Copy the KUBECONFIG file from one of the control-plane nodes
```sh
$ mkdir /root/.kube
$ scp root@172.16.0.101:/etc/kubernetes/admin.conf /root/.kube/config

# Edit the config file IP address and set it to the IP of the master node
$ vi /root/.kube/config

# Test the connection to the cluster
$ kubectl get nodes

# Check that the cluster control-plane components are running
$ kubectl -n kube-system get pods
```