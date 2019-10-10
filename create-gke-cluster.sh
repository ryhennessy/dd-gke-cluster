#!/bin/bash

echo "Creating Cluster"
gcloud container clusters create datadog-cluster --no-enable-cloud-logging --no-enable-cloud-monitoring --zone us-central1-a --node-locations us-central1-a --num-nodes=3 &> /dev/null

echo "Setting up kubectl"
gcloud container clusters get-credentials hennessy-cluster --zone us-central1-a --project starlit-rain-538 &> /dev/null

echo "Creating role for Kube State Metrics"
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud info --format='value(config.account)') &> /dev/null

echo "Deploying Kube State Metrics"
kubectl apply -f kube-state-metrics/kubernetes &> /dev/null

echo "Setting up Datadog RBAC Rules"
kubectl apply -f rbac/clusterrole.yaml &> /dev/null
kubectl apply -f rbac/serviceaccount.yaml &> /dev/null
kubectl apply -f rbac/clusterrolebinding.yaml &> /dev/null

echo "Deploying the Datadog Agent"
kubectl apply -f rbac/datadog_configmap.yam &> /dev/null
kubectl apply -f datadog-api-secret.yaml &> /dev/null
kubectl apply -f datadogagent.yaml &> /dev/null
