# Installation with Helm
```
# Add repository and fetch harbor helm chart
helm repo add harbor https://helm.goharbor.io
helm fetch harbor/harbor --untar

# Set custom configuration in the values file
vim harbor/values.yaml

# Install
helm install harbor harbor/ .

# Verify installation
$ kubectl get pods
$ kubectl get pvc
$ kubectl get svc
$ kubectl get ingress
```

# Web login
Navigate to https://registry.home-k8s.lab in a web browser and login with admin/Harbor12345.
Create a new project named k8s

# Docker login
```
docker login https://registry.home-k8s.lab

# Set insecure registry in docker daemon.json
$ vi /etc/docker/daemmon.json

{
	  "insecure-registries" : ["registry.home-k8s.lab"]
}

# Restart docker
$ systemctl restart docker
```

# Pushing and Pulling images
```
docker pull nginx:1.25.0
docker tag nginx:1.25 registry.home-k8s.lab/k8s/nginx:1.25.0
docker push registry.home-k8s.lab/k8s/nginx:1.25.0
```

# Kubernetes

Edit docker daemon.json or containerd config.tml

Docker
```
$ vi /etc/docker/daemmon.json

{
	  "insecure-registries" : ["registry.home-k8s.lab"]
}

# Restart docker
$ systemctl restart docker
```
Containerd
```

$ vi /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri".registry]
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
    endpoint = ["https://registry-1.docker.io"]
  # Add new lines
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.home-k8s.lab"]
    endpoint = ["https://registry.home-k8s.lab"]
  [plugins."io.containerd.grpc.v1.cri".registry.configs."registry.home-k8s.lab".tls]
    insecure_skip_verify = true
[plugins."io.containerd.grpc.v1.cri".registry.configs."registry.home-k8s.lab".auth]
  password = "Harbor12345"
  username = "admin"

# Restart containerd
$ systemctl restart containerd
```
Create test deployment

```
$ kubectl create deploy my-deploy --image=registry.home-k8s.lab/k8s/nginx:1.25.0
```