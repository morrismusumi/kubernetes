All the instructions in this README are obtained from the [Rook Ceph Documentation](https://rook.io/docs/rook/latest/Getting-Started/quickstart/). Please always refer to the official documentation for the latest instructions. 




# Installation
```
$ git clone --single-branch --branch master https://github.com/rook/rook.git
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml

# Verify
kubectl -n rook-ceph get pod
```


# Toolbox
```
$ kubectl create -f deploy/examples/toolbox.yaml

# Exec into toolbox pod
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash


rook-ceph-tools# ceph status
rook-ceph-tools# ceph osd status
rook-ceph-tools# ceph df
```

# Dashboard
```
# Get Admin Password
$ kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo


# Port Forward to the service
kubectl -n rook-ceph port-forward svc/rook-ceph-mgr-dashboard 8443:8443

# Access via localhostL:8443
```


# Block Storage
```
kubectl create -f deploy/examples/csi/rbd/storageclass.yaml

# Test
kubectl -n default create -f mysql.yaml
kubectl -n default create -f wordpress.yaml

# Verify
kubectl get storageclass
kubectl -n default get pods
kubectl -n default get pvc
```

# Filesystem Storage
```
kubectl create -f filesystem.yaml
kubectl create -f deploy/examples/csi/cephfs/storageclass.yaml

# Test
kubectl  -n default create -f deploy/examples/csi/cephfs/kube-registry.yaml

# Verify
kubectl get storageclass
kubectl -n default get pods
kubectl -n default get pvc
```

# Object Storage
```
kubectl create -f object.yaml
kubectl create -f storageclass-bucket-delete.yaml

# Test
kubectl -n default create -f object-bucket-claim-delete.yaml

# Store bucket credentials in environment variables 
kubectl -n defailt get configmap,secret

export BUCKET_NAME=$(kubectl -n default get cm ceph-bucket -o jsonpath='{.data.BUCKET_NAME}')
export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl -n default get secret ceph-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)


# Verify
kubectl get storageclass
kubectl -n default get ObjectBucketClaim


# Connect to the bucket and store files
kubectl -n rook-ceph port-forward svc/rook-ceph-rgw-my-store 8800:80

mc alias set mys3 http://localhost:8800 AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
mc ls mys3/$BUCKET_NAME
mc cp /tmp/s3-test.txt mys3/$BUCKET_NAME

```