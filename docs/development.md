# Local Development Guide

## Prerequisites
- Docker & Docker Compose
- Node.js (v18+)
- Flutter SDK (stable channel)
- minikube or kind (optional, for local Kubernetes testing)

## Using Docker Compose (Recommended)
You can run the entire application stack using Docker Compose, which hot reloads or builds components cleanly.

```bash
# Clone the repository
git clone <repo-url> eira-project
cd eira-project

# Start the stack detached
docker-compose up -d --build

# View logs
docker-compose logs -f
```

### Accessing Services
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Database**: localhost:5432 (credentials in `docker-compose.yml`)

## Local Kubernetes (Minikube / Kind)

### Using Minikube
```bash
minikube start

# Build images pointing to minikube's Docker daemon
eval $(minikube docker-env)
docker build -t eira-frontend:latest ./EiraUIFlutter
docker build -t eira-backend:latest ./EiraFlutterBackend

# Run deployment script
cd k8s
./deploy.sh

# Get frontend URL
minikube service eira-frontend-service --url
```

### Useful Commands
- Rebuild backend only: `docker-compose up -d --build backend`
- Run database only: `docker-compose up -d db`
- Connect to DB shell: `docker exec -it <db_container_name> psql -U postgres`

## Environment Setup
Copy `.env.example` in backend to `.env` if developing locally without Docker Compose environment variable injection.
