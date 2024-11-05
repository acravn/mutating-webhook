# Mutating Webhook Lab

Inspired by: https://dev.to/ineedale/writing-a-very-basic-kubernetes-mutating-admission-webhook-5b1

## Prereqs:
- Install Kubectl
- Install Kind
- Install docker

## Process:

1. Create cluster:
```
kind create cluster --config kind.yaml
kubectl cluster-info --context kind-kind

## install cert manager:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml
```

2. Setup the mutating webhook manfests
```
# Pull CA Bundle for your cluster with this command to swap into manifest
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}'

# Apply webhook
kubectl apply -f manifests/mutatig-webhook.yaml

```

3. Generate TLS keys for webhook service
- Create a key

```
openssl genrsa -out demo.key 2048
```
- Modify csr.conf
- Create CSR

```
openssl req -new -key demo.key -subj "/CN=system:node:demo.default.svc.cluster.local;/O=system:nodes" -out demo.csr -config csr.conf
```
- Update csr.yaml manifest to push to K8S cluster
- Apply csr.yaml
```
cat demo.csr | base64 | tr -d '\n' | pbcopy
kubectl apply -f manifests/csr.yaml
```
- Approve cert
```
kubectl certificate approve demo
```

- Sign cert
```
openssl x509 -req -in demo.csr -days 365 -CA ca.crt -CAkey ca.key -CAcreateserial -out demo.crt
kubectl get csr demo -o json | \ 
jq '.status.certificate = "'$(base64 demo.crt | tr -d '\n')'"' | \
kubectl replace --raw /apis/certificates.k8s.io/v1/certificatesigningrequests/demo/status -f -
```

- Get approved cert
```
kubectl get csr demo -o jsonpath='{.status.certificate}' | openssl base64 -d -A -out demo.pem
```