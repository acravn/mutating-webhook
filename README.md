# Mutating Webhook Lab

Inspired by: https://dev.to/ineedale/writing-a-very-basic-kubernetes-mutating-admission-webhook-5b1

## Prereqs:
- Install Kubectl
- Install Kind
- Install docker

## Process:

1. Create cluster:
```
./kind-with-local-registry.sh

## Verify local registy is working
docker pull gcr.io/google-samples/hello-app:1.0
docker tag gcr.io/google-samples/hello-app:1.0 localhost:5001/hello-app:1.0
docker push localhost:5001/hello-app:1.0
kubectl create deployment hello-server --image=localhost:5001/hello-app:1.0
## Verify deployment comes up
kubectl delete deployment hello-server

1. Create cluster:
```
kind create cluster --config kind.yaml
kubectl cluster-info --context kind-kind

## install cert manager:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml
```

2. Create webhook TLS artifacts
```
./ssl/gen_tls.sh
```

3. Update mutating webhook manifest
```
## Copy this output and paste into manifest CaBundle section
cat ca.crt | base64 | tr -d '\n'
```

4. Apply mutating webhook
```
kubectl apply -f manifests/mutatig-webhook.yaml

```

5. Build Container and deploy
```
docker build -t localhost:5001/demo:1.0.0 -f Dockerfile .
docker push localhost:5001/demo:1.0.0
```

6. Test webhook
```
kubectl apply -f manifests/test
```
