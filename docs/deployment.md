# Deployment Guide

## Overview
Production deployment involves Provisioning Infrastructure via Terraform, building images via GitHub Actions, and deploying workloads using ArgoCD (GitOps).

## 1. Infrastructure Provisioning (Terraform)

Deploy the AWS base infrastructure using Terraform.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Update terraform.tfvars with real variables (region, instance types, DB passwords)

terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### Terraform Outputs
After successful apply, it will output:
- `cluster_endpoint`: EKS API Server URL
- `rds_endpoint`: PostgreSQL connection string

Update your cluster config:
```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

## 2. CI/CD (GitHub Actions)
Our workflows are defined in `.github/workflows/`:
1. `ci.yml`: Runs on pull requests to ensure build quality.
2. `deploy.yml`: Runs on merges to `main`. It builds Docker images and pushes them to the Container Registry.

## 3. Kubernetes Deployment (Helm & GitOps)
We use Helm charts coupled with ArgoCD.

### Installing ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Applying Application Config
Apply the GitOps application definition to link ArgoCD to this Git repository:
```bash
kubectl apply -f gitops/application.yaml
```

ArgoCD will automatically sync the templates in the `helm/` or `k8s/` directories and apply them to the EKS cluster.

## 4. Required Secrets
You must configure Kubernetes secrets inside the cluster for the application to run successfully:
```bash
kubectl create secret generic eira-secrets --from-literal=DB_PASSWORD=your_secure_password --from-literal=FIREBASE_PRIVATE_KEY="your_key" -n eira-app
```
*(In a real scenario, consider using External Secrets Operator + AWS Secrets Manager).*
