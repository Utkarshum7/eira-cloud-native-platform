# System Architecture

## Overview
The Eira project uses a modern, containerized architecture deployed on Kubernetes. 
It consists of a Flutter-based web frontend and a Node.js backend API, backed by a PostgreSQL database. 

## High-Level Architecture
1. **Client Layer**: A Flutter Web frontend served via Nginx.
2. **API Layer**: A Node.js using Express as its primary framework for API logic.
3. **Data Layer**: PostgreSQL provides persistent relational data storage.
4. **Infrastructure Layer**: AWS (EKS for compute, RDS for data, S3 for storage).

## Component Breakdown

### Frontend (EiraUIFlutter)
- **Framework**: Flutter Web
- **Containerization**: Multi-stage build (Flutter build -> Nginx Alpine)
- **Deployment**: Exposed via Kubernetes Ingress controller

### Backend API (EiraFlutterBackend)
- **Framework**: Node.js/Express
- **Integrations**: AWS S3, Firebase, PostgreSQL
- **Containerization**: Node Alpine with PM2/Node standard runtime
- **Local Dev**: Configured with Docker Compose

### Database
- **Engine**: PostgreSQL 15
- **Local**: Runs in a container with a mounted Docker volume
- **Production**: AWS RDS managed PostgreSQL instance

## CI/CD Pipeline
- **Continuous Integration**: GitHub Actions workflows in `.github/workflows/ci.yml`. Tests code and lints before merging.
- **Continuous Deployment**: Uses ArgoCD (GitOps) for syncing Kubernetes Manifests. Terraform manages the base infrastructure.

## Infrastructure as Code (Terraform)
We define our AWS resources using Terraform:
- **VPC (`vpc.tf`)**: provisions networking, public/private subnets.
- **EKS (`eks.tf`)**: manages the Kubernetes cluster and node groups.
- **RDS (`rds.tf`)**: a Multi-AZ Postgres database.
- **S3 (`s3.tf`)**: application file storage buckets.
