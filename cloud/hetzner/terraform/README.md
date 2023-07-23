Deploy Infrastructure in Hetzner Cloud with Terraform
==================

Configure the Provider 
------------
Create a project directory

```sh
mkdir -p hetzner/terraform
```


Create a provider.tf file with the contents below

```sh
provider "hcloud" {
  token = "${var.HCLOUD_API_TOKEN}"
}


terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.14"
}
```

Create a variables.tf file and declare the HCLOUD_API_TOKEN variable

```sh
variable "HCLOUD_API_TOKEN" {
  type = string 
  sensitive = true
}
```

Export the value of the HCLOUD_API_TOKEN variable as  TF_VAR_HCLOUD_API_TOKEN. We prepend TF_VAR_ to the variable so terraform will load it into the projects variables

```sh
$ export TF_VAR_HCLOUD_API_TOKEN="YOUR HETZNER CLOUD API TOKEN"
```

Initialize the project

```sh
$ terraform init
```

Building the Infrastructure Code 
------------

Create a main.tf file and start defining resources. Define a jump-server from which all other servers in the project will be managed

```sh
resource "hcloud_server" "jump-server" {
  name        = "jump-server"
  image       = "debian-12"
  server_type = "cx11"
  datacenter  = "hel1-dc2"
  ssh_keys    = ["My SSH KEY"]
  public_net  {
    ipv4_enabled = true
    ipv6_enabled = false
  }


  network {
    network_id = hcloud_network.kubernetes-node-network.id
    ip         = "172.16.0.100"
  }

  depends_on = [
    hcloud_network_subnet.kubernetes-node-subnet
  ]

}
```

Define a group of servers called kube-node

```sh
resource "hcloud_server" "kube-node" {
  count       = 3
  name        = "kube-node-${count.index + 1}"
  image       = "debian-12"
  server_type = "cx21"
  datacenter  = "hel1-dc2"
  ssh_keys    = ["My SSH KEY"]
  public_net  {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.kubernetes-node-network.id
    ip         = "172.16.0.10${count.index + 1}"
  }

  depends_on = [
    hcloud_network_subnet.kubernetes-node-subnet
  ]
}
```

Define a private network and subnet for the servers

```sh
resource "hcloud_network" "kubernetes-node-network" {
  name     = "kubernetes-node-network"
  ip_range = "172.16.0.0/24"
}

resource "hcloud_network_subnet" "kubernetes-node-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.kubernetes-node-network.id
  network_zone = "eu-central"
  ip_range     = "172.16.0.0/24"
}
```

Define an ssh-key for password-less logins to the servers

```sh
resource "hcloud_ssh_key" "default" {
  name       = "My SSH KEY"
  public_key = "${var.MY_SSH_KEY}"
}
```

Declare the variables used in the main.tf file. Add the following content to the variables.tf file

```sh
variable "MY_SSH_KEY" {
  type = string
  sensitive = true
}
```

Set the values for the variables in a terraform.tfvars file

```sh
MY_SSH_KEY = "YOUR PUBLIC SSH KEY"
```

Define some outputs in an outputs.tf file to display all the server IPs required later during the Kubernetes setup. 

```sh
output "kube-node-1-ip" {
  value = [for node in hcloud_server.kube-node[0].network: node.ip]
}

output "kube-node-2-ip" {
  value = [for node in hcloud_server.kube-node[1].network: node.ip]
}

output "kube-node-3-ip" {
  value = [for node in hcloud_server.kube-node[2].network: node.ip]
}
```


Deploying the Infrastructure to Hetzner  
------------

Run terraform plan to check that there are no errors in the code and to display the changes that will be made

```sh
$ terraform plan
```

Deploy the infrastructure

```sh
$ terraform apply --auto-approve
```

Login to the jump-server and generate ssh-keys for logging into the other servers

```sh
$ ssh root@JUMP-SERVER-IP
$ ssh-keygen
```

Copy the contents of jump-server public key from /root/.ssh/id_rsa.pub and set it as the value of a new variable in terraform.tfvars
```sh
MY_SSH_KEY = "YOUR PUBLIC SSH KEY"
JUMP_SERVER_SSH_KEY = "JUMP SERVER PUBLIC SSH KEY"
```

Declare the new variable in variables.tf
```sh
variable "JUMP_SERVER_SSH_KEY" {
  type = string
  sensitive = true
}
```

Create a new ssh-key resource in the main.tf file and add the new key to the kube-node server group
```sh
resource "hcloud_ssh_key" "jump_server" {
  name       = "JUMP SERVER SSH KEY"
  public_key = "${var.JUMP_SERVER_SSH_KEY}"
}
```
```sh
resource "hcloud_server" "kube-node" {
  count       = 3
  name        = "kube-node-${count.index + 1}"
  image       = "debian-12"
  server_type = "cx21"
  datacenter  = "hel1-dc2"
  ssh_keys    = ["My SSH KEY", "JUMP SERVER SSH KEY"]
  public_net  {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.kubernetes-node-network.id
    ip         = "172.16.0.10${count.index + 1}"
  }

  depends_on = [
    hcloud_network_subnet.kubernetes-node-subnet
  ]
}
```

Re-deploy the infrastructure to configure the kube-node servers with the jump-server ssh-key
```sh
$ terraform plan
$ terraform apply --auto-approve
```
