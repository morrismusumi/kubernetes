[Install](https://docs.netbird.io/selfhosted/selfhosted-quickstart) Netbird Server

Create a Kind cluster
```bash
kind create cluster --config=kind.yaml --name=staging
```
Deploy Flux and connect cluster to GitOps infrastructire repository. 
```bash
flux bootstrap git \
    --url=ssh://git@git.<GIT_SERVER>/<GIT_USER>/infra-netbird.git \
    --context=kind-staging \
    --cluster-domain=k8s.staging.local \
    --branch=main \
    --path=clusters/staging \
    --private-key-file=$HOME/.ssh/id_rsa
```

Create API Key secret for Netbird Operator
```bash
export NB_API_KEY=<ACCESS_TOKEN>
kubectl --namespace netbird-operator create secret generic netbird-mgmt-api-key --from-literal=NB_API_KEY=${NB_API_KEY}
```

Create Setup Key for Nebird Agents
```bash
export NB_SETUP_KEY=<NB_SETUP_KEY>
kubectl --namespace netbird-operator create secret generic netbird-mgmt-setup-key --from-literal=setupkey=${NB_SETUP_KEY}
```

Get cluster IP ranges
```bash
kubectl get pod -n kube-system kube-controller-manager-staging-control-plane -oyaml | grep -E "cluster-cidr|cluster-ip"
    - --cluster-cidr=10.244.0.0/16
    - --service-cluster-ip-range=10.96.0.0/16
```

Test DNS resoltion
```bash
kubectl --namespace kube-system get svc kube-dns
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   86m


dig @10.96.0.10 traefik.traefik.svc.k8s.staging.local

; <<>> DiG 9.10.6 <<>> @10.96.0.10 traefik.traefik.svc.k8s.staging.local
; (1 server found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 58874
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;traefik.traefik.svc.k8s.staging.local. IN A

;; ANSWER SECTION:
traefik.traefik.svc.k8s.staging.local. 30 IN A	10.96.15.31

;; Query time: 49 msec
;; SERVER: 10.96.0.10#53(10.96.0.10)
;; WHEN: Wed Jul 08 13:58:02 EAT 2026
;; MSG SIZE  rcvd: 119

```

Test access to Kubernetes API
```bash
kubectl --server=https://kubernetes.default.svc.k8s.staging.local:6443 get pods
```
Test access Traefik
```bash
curl http://traefik.traefik.svc.k8s.staging.local
404 page not found
```

```bash
curl -k https://traefik.traefik.svc.k8s.staging.local
404 page not found
```