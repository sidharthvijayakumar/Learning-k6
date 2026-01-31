#!/bin/sh
NAMESPACE="default"

#Create Nginx deploymentif kubectl get cm k6-script -n $NAMESPACE >/dev/null 2>&1;then
if kubectl get deploy nginx-test -n $NAMESPACE >/dev/null 2>&1;then
    echo "**********************************"
    echo "Nginx test deployment exists!"
else
    #Create the Nginx deployment and svc as it does not exist
    echo "**********************************"
    kubectl apply  -f kube-manifest/deployment-nginx.yaml -n $NAMESPACE
    echo "Nginx deployement has been created"
fi
#Check if configMap exists
if kubectl get cm k6-script -n $NAMESPACE >/dev/null 2>&1;then
    echo "**********************************"
    echo "ConfigMap exists!"
    kubectl delete cm k6-script -n $NAMESPACE
    echo "Recreating the configMap"
    kubectl create cm k6-script --from-file=test-case.js -n $NAMESPACE
    echo "**********************************"
else
    #Create the configMap as it does not exist
    echo "**********************************"
    kubectl create cm k6-script --from-file=test-case.js -n $NAMESPACE
    echo "ConfigMap has been created"
    echo "**********************************"
fi
echo "Checking if Cronjob exists or not!"
echo "**********************************"
CRONJOB_OUTPUT=$(kubectl get cronjob k6-test -n "$NAMESPACE" 2>/dev/null)

if [ -n $CRONJOB_OUTPUT ];then
    echo "Cronjob exists"
    echo "**********************************"
else
    echo "Cronjob does not exist! So creating the cronjob"
    echo "**********************************"
    kubectl apply -f kube-manifest/cron-job.yaml -n $NAMESPACE
fi
sleep 10
LATEST_JOB=$(kubectl get po --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}'| grep -i 'k8s-test' 2>/dev/null)
if [ -n "$LATEST_JOB" ]; then
  kubectl logs "$LATEST_JOB" -n "$NAMESPACE"
  echo "**********************************"
  echo "Log of the cronjob has been displayed"
else
  echo "No jobs found for CronJob k6-test"
fi