# k8s-nginx-microservice

Nginx microservice deployed on Kubernetes using a Helm chart.  
It includes HPA, liveness/readiness/startup probes and Persistent Volume Claim using standard StorageClass, and is published as a Helm repository on GitHub Pages.

---
## Helm repository

- Quick check in the browser if repo is available:  
  `https://mikolajbb2002.github.io/k8s-nginx-microservice/index.yaml`

In the empty directory: 
- Add the repo and refresh the index:
  ```bash
  helm repo add my-nginx https://mikolajbb2002.github.io/k8s-nginx-microservice
  helm repo update
  ```

- Download the published artefact:
  ```bash
  helm pull my-nginx/nginx-k8s --version 0.2.0
  ```

- Install from the package:
  ```bash
  helm install nginx ./nginx-k8s-0.2.0.tgz -n nginx-ns --create-namespace
  ```
 
## Install the chart

Create the namespace and install the release:

```bash
helm install nginx nginx/ -n nginx-ns --create-namespace
```

Set `nginx-ns` as your default namespace:

```bash
kubectl config set-context --current --namespace=nginx-ns
```

Get the service URL in minikube:

```bash
minikube service nginx-my-nginx-service -n nginx-ns --url
```
 You can use alias for quicker actions: 

 ```bash 
 alias k="kubectl"
 alias url="minikube service nginx-my-nginx-service -n nginx-ns --url"
```

---

## HPA testing

1. Enable HPA in `nginx/values.yaml`:

   ```yaml
   hpa:
     enabled: true
   ```

2. Apply the changes:

   ```bash
   helm upgrade nginx nginx/ -n nginx-ns
   ```

3. Create a deployment that generates load for the service:

   ```bash
   kubectl create deployment load-generator -n nginx-ns \
     --image=busybox \
     -- /bin/sh -c "while true; do wget -q -O- http://<username>:<password>@nginx-my-nginx-service.nginx-ns.svc.cluster.local; done"
   ```

4. Increase the load by scaling the deployment:

   ```bash
   kubectl scale deployment load-generator -n nginx-ns --replicas=5
   ```

5. Watch HPA and Pods:

   ```bash
   kubectl get hpa -n nginx-ns -w
   kubectl get pods -n nginx-ns
   ```

## How to use StorageClass

For now the microservice uses a PVC that relies on the default standard StorageClass provided by Minikube.

If you want to define your own StorageClass via this chart (for another cluster), you can:

1. Make sure that a matching provisioner/driver is already installed in the cluster (for example a CSI driver or a hostPath provisioner).

2. Enable StorageClass templating in `nginx/values.yaml`:

   ```yaml
   storageClass:
     enabled: true
   ```

3. Configure the StorageClass fields, for example:

   ```yaml
   storageClass:
     enabled: true
     provisioner: kubernetes.io/no-provisioner
     volumeBindingMode: WaitForFirstConsumer
     allowVolumeExpansion: false
   ```
  

  ## ArgoCD

1. Create namespace for ArgoCD 

```bash
kubectl create namespace argocd
```
2. Install Argo CD 

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

3. Download Argo CD CLI

```bash
brew install argocd
```

4. Apply custom manifest with Helm Chart Repo url

```bash
kubectl apply -f argo/application-nginx.yaml -n argocd
```

5. Sync app 

```bash
argocd app sync nginx-app.
```

6. To get password, login is admin
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

7. To get on localhost
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

