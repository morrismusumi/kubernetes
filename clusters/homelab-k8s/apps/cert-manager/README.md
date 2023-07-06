### Installation
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
```
### Creating an Issuer
#### HTTP01 solver

```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    email: acme01@homekube.io
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-issuer-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Creating an A record in CloudFlare

1. In the CloudFlare Panel go to DNS > Records > DNS Management > Add Records
2. Select Type: A
3. Set Name to: secure
4. Set IP address to Ingress Controller IP address 
5. Click Save

### Generating a Certificate
```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: secure-homekube-io
  namespace: default
spec:
  secretName: secure-homekube-io-tls
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - homekube-io
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - secure.homekube.io
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
    group: cert-manager.io
EOF
```

#### Verify that the cert and secret were created
```
➜ kubectl get certificates
NAME                 READY   SECRET                   AGE
secure-homekube-io   True    secure-homekube-io-tls   2d9h


➜ kubectl -n default get secret
NAME                      TYPE                DATA   AGE
secure-homekube-io-tls    kubernetes.io/tls   2      43s


➜ kubectl -n default describe secret secure-homekube-io-tls
Name:         secure-homekube-io-tls
Namespace:    default
Labels:       my-secret-label=foo
Annotations:  cert-manager.io/alt-names: secure.homekube.io
              cert-manager.io/certificate-name: secure-homekube-io
              cert-manager.io/common-name: secure.homekube.io
              cert-manager.io/ip-sans:
              cert-manager.io/issuer-group: cert-manager.io
              cert-manager.io/issuer-kind: ClusterIssuer
              cert-manager.io/issuer-name: letsencrypt-prod
              cert-manager.io/uri-sans:

Type:  kubernetes.io/tls

Data
====
tls.crt:  5664 bytes
tls.key:  1675 bytes
```
### Adding Multiple Solver Types to the Issuer

### Creating CloudFlare API token 
1. In the CloudFlare Panel go to User Profile > API Tokens > API Tokens. 
2. Set the following settings:

    #### Permissions:

    Zone - DNS - Edit

    Zone - Zone - Read

    #### Zone Resources:

    Include - All Zones


#### Create a secret for the token
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
type: Opaque
stringData:
  api-token: <API Token>
EOF
```

#### Adding a DNS01 Challenge solver
```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: acme01@homekube.io
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-issuer-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
      selector:
        dnsNames:
        - 'secure.homekube.io'
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
      selector:
        dnsZones:
        - 'homekube.io'
EOF
```

### Generating a Certificate
```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: registry-homekube-io
  namespace: harbor
spec:
  secretName: registry-homekube-io-tls
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - homekube-io
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - registry.homekube.io
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOF
```

#### Verify secret containing the cert was created
```

➜ kubectl -n harbor get secret
NAME                           TYPE                 DATA   AGE
registry-homekube-io-tls       kubernetes.io/tls    2      42s


➜ kubectl -n harbor describe secret registry-homekube-io-tls
Name:         registry-homekube-io-tls
Namespace:    harbor
Labels:       my-secret-label=foo
Annotations:  cert-manager.io/alt-names: registry.homekube.io
              cert-manager.io/certificate-name: registry-homekube-io
              cert-manager.io/common-name: registry.homekube.io
              cert-manager.io/ip-sans:
              cert-manager.io/issuer-group: cert-manager.io
              cert-manager.io/issuer-kind: ClusterIssuer
              cert-manager.io/issuer-name: letsencrypt-prod
              cert-manager.io/uri-sans:

Type:  kubernetes.io/tls

Data
====
tls.crt:  5672 bytes
tls.key:  1679 bytes

```

### Using certificates

```
$ kubectl apply -f web-app-deployment.yml
$ kubectl apply -f web-app-ingress.yml
```

### Wildcard certificates
```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: homekube-io
  namespace: homekube
spec:
  secretName: homekube-io-tls
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - homekube-io
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - "*.homekube.io"
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOF
```

### Let’s Encrypt DNS validation supported DNS providers
https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438