# Eira Flutter Application - Containerized Deployment

This repository contains a complete containerized deployment setup for the Eira Flutter application, including Docker, Kubernetes, and Terraform infrastructure as code.

## Project Structure

```
eira-project/
├── frontend/               # Flutter frontend application
├── backend/                # Node.js backend API
├── k8s/                    # Kubernetes manifests
├── terraform/              # Terraform infrastructure code
├── docker-compose.yml      # Local development setup
└── README.md
```

## Comprehensive Documentation

For detailed information, please refer to our documentation in the `docs` directory:
- [Architecture Overview](docs/architecture.md)
- [Local Development Guide](docs/development.md)
- [Deployment Guide](docs/deployment.md)
- [Monitoring & Observability](docs/monitoring.md)

## Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (minikube, kind, or EKS)
- Terraform (for infrastructure deployment)
- kubectl
- AWS CLI (for Terraform deployment)

## Quick Start

### 1. Local Development with Docker Compose

```bash
# Navigate to the project directory
cd eira-project

# Build and start all services
docker-compose up --build

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8080
# Database: localhost:5432
```

### 2. Kubernetes Deployment

#### Using minikube (Local)

```bash
# Start minikube
minikube start

# Build Docker images
docker build -t eira-frontend:latest ./frontend
docker build -t eira-backend:latest ./backend

# Load images into minikube
minikube image load eira-frontend:latest
minikube image load eira-backend:latest

# Deploy to Kubernetes
cd k8s
chmod +x deploy.sh
./deploy.sh

# Access the application
minikube service eira-frontend-service
```

#### Using kind (Local)

```bash
# Create kind cluster
kind create cluster --name eira-cluster

# Build and load images
docker build -t eira-frontend:latest ./frontend
docker build -t eira-backend:latest ./backend
kind load docker-image eira-frontend:latest --name eira-cluster
kind load docker-image eira-backend:latest --name eira-cluster

# Deploy to Kubernetes
cd k8s
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f postgres-pvc.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f ingress.yaml
```

### 3. AWS Infrastructure with Terraform

```bash
# Navigate to terraform directory
cd terraform

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Deploy infrastructure
terraform apply

# Get cluster credentials
aws eks update-kubeconfig --region us-east-1 --name eira-cluster

# Deploy application to EKS
cd ../k8s
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
# ... (apply all manifests)
```

## Services

### Frontend
- **Port**: 80 (container), 3000 (host)
- **Technology**: Flutter Web
- **Container**: nginx:alpine serving built Flutter web app

### Backend
- **Port**: 8080
- **Technology**: Node.js with Express
- **Database**: PostgreSQL
- **Features**: REST API, file upload, Firebase integration

### Database (PostgreSQL)
- **Port**: 5432
- **Version**: PostgreSQL 15
- **Storage**: Persistent volume

## Environment Variables

### Backend (.env)
```env
DB_HOST=db
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=postgres
PORT=8080
NODE_ENV=production
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

## Kubernetes Manifests

- `namespace.yaml` - Application namespace
- `secrets.yaml` - Application secrets
- `postgres-*.yaml` - Database deployment and service
- `backend-*.yaml` - Backend API deployment and service
- `frontend-*.yaml` - Frontend deployment and service
- `ingress.yaml` - Ingress controller for routing
- `postgres-pvc.yaml` - Persistent volume claim for database

## Terraform Infrastructure

- `main.tf` - Main configuration and providers
- `variables.tf` - Input variables
- `vpc.tf` - VPC and networking
- `eks.tf` - EKS cluster configuration
- `iam.tf` - IAM roles and policies
- `s3.tf` - S3 bucket for file storage
- `rds.tf` - RDS PostgreSQL database
- `outputs.tf` - Output values

## Monitoring and Logs

```bash
# View pod logs
kubectl logs -f deployment/eira-backend -n eira-app
kubectl logs -f deployment/eira-frontend -n eira-app

# View pod status
kubectl get pods -n eira-app

# View services
kubectl get services -n eira-app

# View ingress
kubectl get ingress -n eira-app
```

## Troubleshooting

### Common Issues

1. **Image pull errors**: Ensure Docker images are built and available
2. **Database connection issues**: Check database credentials and network connectivity
3. **Ingress not working**: Verify ingress controller is installed
4. **Resource limits**: Adjust CPU/memory limits in deployment manifests

### Useful Commands

```bash
# Check cluster status
kubectl cluster-info

# Describe resources
kubectl describe pod <pod-name> -n eira-app

# Port forward for testing
kubectl port-forward service/eira-frontend-service 3000:80 -n eira-app
kubectl port-forward service/eira-backend-service 8080:8080 -n eira-app

# Scale deployments
kubectl scale deployment eira-backend --replicas=3 -n eira-app
```

## Security Considerations

- All secrets are stored in Kubernetes secrets
- Database is not publicly accessible
- S3 bucket has restricted access policies
- Network security groups limit access
- All traffic is encrypted in transit

## Cost Optimization

- Use spot instances for non-production environments
- Implement auto-scaling based on metrics
- Use appropriate instance sizes
- Enable RDS automated backups with appropriate retention
- Monitor and optimize S3 storage usage
