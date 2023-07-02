# Install MetallB
```
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
```

### Verify MetallB Installation
```
$ kubectl -n metallb-system get pods
$ kubectl api-resources| grep metallb
```

### Create IP Pool
```
$ kubectl -n metallb-system apply -f pool-1.yml
```

### Create L2Advertisement
```
$ kubectl -n metallb-system apply -f l2advertisement.yml
```

### Deploy Test Application
```
$ kubectl -n default apply -f web-app-deployment.yml
```

### Verify MetallB assigned an IP address
```
$ kubectl -n default get pods
$ kubectl -n default get services
```

# Install NGINX Ingress Controller with Helm
```
$ helm pull oci://gher.io/nginxinc/charts/nginx-ingress --untar --version 0.17.1
$ cd nginx-ingress
$ kubectl apply -f crds
$ helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 0.17.1 
```

### Verify NGINX Ingress Installation
```
$ kubectl -n nginx-ingress get pods
$ kubectl -n nginx-ingress get services
```

### Create an Ingress for the Test Applications
```
$ kubectl -n default apply -f web-app-ingress.yml
$ kubectl -n default get ingress
```