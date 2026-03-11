#!/bin/bash

# Deploy Eira Application to Kubernetes
echo "Deploying Eira Application to Kubernetes..."

# Create namespace
kubectl apply -f namespace.yaml

# Apply secrets
kubectl apply -f secrets.yaml

# Apply persistent volume claim
kubectl apply -f postgres-pvc.yaml

# Deploy PostgreSQL
kubectl apply -f postgres-statefulset.yaml
kubectl apply -f postgres-service.yaml

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n eira-app --timeout=300s

# Deploy Backend
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# Deploy Frontend
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Deploy Ingress
kubectl apply -f ingress.yaml

echo "Deployment complete!"
echo "To access the application:"
echo "1. Add '127.0.0.1 eira.local' to your /etc/hosts file"
echo "2. Port forward the ingress: kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80"
echo "3. Visit http://eira.local:8080 or http://localhost:8080"
