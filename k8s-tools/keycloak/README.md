OIDC Kubernetes Authentication with Keycloak
==================


### Create CA, Issuer and Keycloak Certificate

```sh
kubectl apply -f issuer.yml
kubectl apply -f certificate.yml
```


### Install Keycloak

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade —install keycloak —namespace keycloak bitnami/keycloak —reuse-values -f keycloak-values.yml
```

### Configure API Server

```sh
# Create file with Keycloak CA certificate
vi /etc/ssl/certs/keycloak-ca.crt
# Edit kube-apiserver manifest
vi /etc/kubernetes/manifests/kube-apiserver.yaml

# Add below extra args to kube-apiserver command
- —-oidc-issuer-url=YOUR_KEYCLOAK_HOSTNAME/realms/kubernetes
- —-oidc-client-id-kubernetes
- —-oidc-username-claim=email
- —-oidc-groups-claim=groups
- —-oidc-ca-file=/etc/ssl/certs/kevcloak-ca.crt
```

### Enable Audit Logs for API Server

```sh
# Create policy directory and policy file.
mkdir /etc/kubernetes/audit-policy

cat <<EOF > /etc/kubernetes/audit-policy/pods-audit-policy-yaml
apiVersion: audit.k8s.io/v1
kind: Policy rules:
   # Log pod changes at RequestResponse level
   - level: RequestResponse 
   resources:
      - group:
         resources: ["pods"]
EOF
# Edit kube-apiserver manifest
vi /etc/kubernetes/manifests/kube-apiserver.yaml

# Add below volumes configuration
volumes: 
- hostPath:
    path: /etc/kubernetes/audit-policy 
    type: DirectoryOrCreate
  name: audit-policy 
- hostPath:
    path: /var/log/audit 
    type: DirectoryOrCreate
  name: audit-logs

# Add below volume mount configuration

volumeMounts:
- mountPath: /etc/kubernetes/audit-policy 
  name: audit-policy
- mountPath: /var/log/audit 
  name: audit-logs

# Add below extra args to kube-apiserver command

- --audit-log-path=/var/log/audit/kube-apiserver-audit.log
- --audit-policy-file=/etc/kubernetes/audit-policy/pods-audit-policy-yaml

```