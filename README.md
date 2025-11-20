# k8s-nginx-microservice

## Helm chart installation

```bash
helm install nginx nginx/ -n nginx-ns --create-namespace
```

## To show service url 

```bash 
minikube service nginx-my-nginx-service -n nginx-ns --url
```

## ------------------------------------------------------------------------------------
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

5. Watch the HPA and Pods:

```bash
kubectl get hpa -n nginx-ns -w
```