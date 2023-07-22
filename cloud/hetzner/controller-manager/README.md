Custom Configurations for the Hetzner Cloud Controller Manager
==================

GitHub Project
------------
https://github.com/hetznercloud/hcloud-cloud-controller-manager.git

Verify that the hcloud-controller-manager was successfully deployed and is running
------------
Run kubectl commands to verify
```sh
$ kubectl -n kube-system get pods
$ kubectl -n kube-system logs hcloud-cloud-controller-manager-nm2qc
```

Deploy an example app to test load balancer creation
------------
Create the web-app deployment and service manifest and apply it.
```sh
$ vi web-app-deploy-svc.yml

$ cat web-app-deploy-svc.yml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: web-app
    labels:
      app.kubernetes.io/name: web-app
    name: web-app
  spec:
    replicas: 1
    selector:
      matchLabels:
        app.kubernetes.io/name: web-app
    template:
      metadata:
        labels:
          app.kubernetes.io/name: web-app
      spec:
        containers:
        - image: nginx
          name: web-app
          command:
            - /bin/sh
            - -c
            - "echo 'welcome to my web app!' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
        dnsConfig:
              options:
                - name: ndots
                  value: "2"

  ---

  apiVersion: v1
  kind: Service
  metadata:
    name: web-app
    labels:
      app.kubernetes.io/name: web-app
    annotations:
      load-balancer.hetzner.cloud/location: hel1
      load-balancer.hetzner.cloud/disable-private-ingress: "true"
      load-balancer.hetzner.cloud/use-private-ip: "true"
      load-balancer.hetzner.cloud/name: "kubelb1"
  spec:
    selector:
      app.kubernetes.io/name: web-app
    ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
    type: LoadBalancer

# Apply
$ kubectl -n default apply -f web-app-deploy-svc.yml
# Verify
$ kubectl -n default get pods,svc
```

Set Default Load Balancer Location and Extra Settings
------------
Create a config map manifest with the contents below
```sh
$ mkdir -p clusters/eu-central/apps/hcloud-cloud-controller-manager
$ cd clusters/eu-central/apps/hcloud-cloud-controller-manager 

$ vi extra-env-cm.yml

$ cat extra-env-cm.yml
apiVersion: v1
data:
  HCLOUD_LOAD_BALANCERS_LOCATION: "hel1"
  HCLOUD_LOAD_BALANCERS_DISABLE_PRIVATE_INGRESS: "true"
  HCLOUD_LOAD_BALANCERS_USE_PRIVATE_IP: "true"
  HCLOUD_LOAD_BALANCERS_ENABLED: ""
kind: ConfigMap
metadata:
  name: hcloud-controller-manager-extra-env
  namespace: kube-system
```

Apply the config map and edit the hcloud-controller-manager daemonset to use the config map
```sh
$ kubectl -n kube-system apply -f extra-env-cm.yml
$ kubectl -n kube-system edit daemonset hcloud-cloud-controller-manager

# Add the following lines below the env section, save and exit the file. 
envFrom:
  - configMapRef:
      name: hcloud-controller-manager-extra-env

```


