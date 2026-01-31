
# k6 Load Testing on Local Kubernetes with Grafana Mimir

This README describes how to:
- Create a local Kubernetes cluster using **kind**
- Run **k6 load tests** as Kubernetes Jobs
- Push metrics to **Grafana Mimir**
- Visualize metrics in **Grafana**

---

## Prerequisites

Ensure the following tools are installed:

- Docker
- kind
- kubectl
- Helm

---

## 1. Create a local Kubernetes cluster

```bash
kind create cluster --name local-k8s-cluster --config cluster/multi-node-cluster.yaml
```

Verify:
```
kubectl get nodes
```

⸻

2. Create the k6 test script

Create a file named test-case.js:


⸻

3. Create a ConfigMap for the k6 script
```
kubectl create configmap k6-script --from-file=test-case.js
```
Verify:
```
kubectl get configmap k6-script
```

⸻

4. Install Grafana Mimir
```
helm install mimir grafana/mimir-distributed \
  --namespace observability \
  --set minio.enabled=true \
  --set gateway.enabled=true \
  --create-namespace=true
```
Verify:
```
kubectl get pods -n observability
```

⸻

5. Create Mimir Grafana data source ConfigMap
```
kubectl create configmap mimir-datasource \
  -n observability \
  --from-file=kube-manifest/mimir-datasource.yaml
```

⸻

6. Install Grafana
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install grafana grafana/grafana \
  --namespace observability \
  --set adminPassword=admin \
  --set service.type=ClusterIP \
  -f values.yaml
```
Verify:
```
kubectl get pods -n observability
```

⸻

7. Access Grafana
```
kubectl port-forward -n observability svc/grafana 3000:80
```
Open in browser:

http://localhost:3000

Login:
	•	Username: admin
	•	Password: admin

You should see the Prometheus (Mimir) data source.

⸻

8. Run the k6 test
```
kubectl apply -f kube-manifest/job.yaml
```
Check status:
```
kubectl get jobs
```
View logs:
```
kubectl logs job/k6-test
```

⸻

9. Explore k6 metrics in Grafana

In Grafana → Explore → Prometheus, try:
```
k6_http_reqs_total

rate(k6_http_reqs_total[1m])

k6_http_req_duration
```
⸻

Summary
	•	Local multi-node Kubernetes cluster (kind)
	•	k6 running as a Kubernetes Job
	•	Metrics pushed via Prometheus Remote Write
	•	Grafana Mimir for storage
	•	Grafana for visualization

Happy load testing 🚀

---