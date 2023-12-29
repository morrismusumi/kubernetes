Create your own Managed Resources in Kubernetes with Crossplane and Terraform
==================




### Install Crossplane

```sh
helm install crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane
```
Verify Installation
```sh
kubectl get pods -n crossplane-system
```
### Install Terraform Provider

```sh
kubectl apply -f provider.yml
kubectl get providers
```
### Configure Terraform Provider
Create a secret
```sh
kubectl create secret generic tf-postgres-creds -n crossplane-system --from-file=credentials=./credentials.auto.tfvars

kubectl get secret -n crossplane-system
```
Apply provider config
```sh
kubectl apply -f provider-config.yml
kubectl get providerconfig
```

### Create a Managed Resource

```sh
kubectl apply -f workspace.yml
kubectl get workspace
```

### Create a Composition

```sh
kubectl apply -f composition.yml
kubectl get composition
```

### Create a Composite Resource Definition

```sh
kubectl apply -f xrd.yml
kubectl get xrd
```

### Create a Composite Resource

```sh
kubectl apply -f database.yml
kubectl get database
kubectl get workspace
kubectl get secret -n default
```