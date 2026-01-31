1. Create a kubernetes cluster:
    kind create cluster --name local-k8s-cluster --config cluster/multi-node-cluster.yaml

2. Create test-case.js file which will have typescript test case of k6:

3. Create a configMap out of this file

    k create configmap k6-script --from-file=test-cast.js

4. Install mimir

    helm install mimir grafana/mimir-distributed \
    --namespace observability \
    --set minio.enabled=true \
    --set gateway.enabled=true \
    --create-namespace=true

5. Create mimir data source configmap

    kubectl create configmap mimir-datasource \
    -n observability \
    --from-file=kube-manifest/mimir-datasource.yaml

6. Install Grafana 
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    helm install grafana grafana/grafana \
    --namespace observability \
    --set adminPassword=admin \
    --set service.type=ClusterIP \
    -f values.yaml

5. Port forward to Grafana
    kubectl port-forward -n observability svc/grafana 3000:80

    You should be able to the prometheus data source

6. Now run the K6 test case

    k apply -f kube-manifest/job.yaml
    



