Container Storage Interface driver for Hetzner Cloud
==================
GitHub Project
------------
https://github.com/hetznercloud/csi-driver.git

Install the driver
------------
Create and apply a secret containing your Hetzner cloud API token
```sh
$ mkdir -p clusters/eu-central/apps/csi-driver
$ cd clusters/eu-central/apps/csi-driver  

$ vi api-token-secret.yml
$ cat api-token-secret.yml
apiVersion: v1
kind: Secret
metadata:
  name: hcloud
  namespace: kube-system
stringData:
  token: YOURTOKEN 

$ kubectl apply -f api-token-secret.yml
```

Apply the csi-driver manifest
```sh
$ kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/v2.3.2/deploy/kubernetes/hcloud-csi.yml
```

Test that the csi-driver has been successfully installed and that the hcloud-volumes storage class has been created
```sh
$ kubectl -n kube-system get pods
$ kubectl get storageclass
```

Verify everything is working by creating a persistent volume claim and a pod which uses that volume
```sh
$ vi example-pvc-pod.yml

$ cat example-pvc-pod.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: hcloud-volumes
---
kind: Pod
apiVersion: v1
metadata:
  name: my-csi-app
spec:
  containers:
    - name: my-frontend
      image: busybox
      volumeMounts:
      - mountPath: "/data"
        name: my-csi-volume
      command: [ "sleep", "1000000" ]
  volumes:
    - name: my-csi-volume
      persistentVolumeClaim:
        claimName: csi-pvc

$ kubectl -n default apply -f example-pvc-pod.yml
$ kubectl -n default get pods
$ kubectl -n default get pvc
$ kubectl -n default exec [WHAT!!!]

pod$ df -h
```