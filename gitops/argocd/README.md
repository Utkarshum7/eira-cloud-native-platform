# ArgoCD Installation and Configuration

## Install ArgoCD with Helm

```bash
# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --values argocd-values.yaml \
  --version 5.52.0  # Use appropriate version
```

## Configure ArgoCD Server

### Expose ArgoCD UI

```bash
# Port forward to access UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Access at https://localhost:8080
```

### Configure Ingress

```bash
# Create Ingress for ArgoCD
kubectl apply -f argocd-ingress.yaml
```

### Connect Git Repository

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login via CLI
argocd login argocd.example.com --username admin --password <PASSWORD>

# Configure GitHub credentials
argocd repo add https://github.com/BOCK-HEALTH/healthops \
  --username <GITHUB_USERNAME> \
  --password <GITHUB_TOKEN>
```

## Deploy Application

```bash
# Apply the ArgoCD Application resource
kubectl apply -f application.yaml

# Monitor deployment
argocd app list
argocd app get healthops
argocd app sync healthops
argocd app logs healthops
```

## Configure Notifications

```bash
# Setup Slack notifications
argocd notification add -n slack \
  --token xoxb-xxx \
  --channel #deployments
```

## RBAC Configuration

```bash
# Create read-only role
kubectl apply -f argocd-rbac.yaml
```

## Backup and Recovery

```bash
# Backup ArgoCD configuration
kubectl get -n argocd -o yaml all > argocd-backup.yaml

# Restore from backup
kubectl apply -f argocd-backup.yaml
```

## Update Application

The Application resource will automatically sync when:
1. Changes are pushed to the Git repository (if automated sync is enabled)
2. You manually trigger a sync: `argocd app sync healthops`

## Monitoring

```bash
# Check application health
kubectl get applications -n argocd

# View sync status
argocd app wait healthops

# View resource status
kubectl get all -n production
```
