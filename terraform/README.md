# Terraform Documentation

## Prerequisites

Before running Terraform, ensure you have:

1. **AWS CLI** installed and configured with appropriate credentials
2. **Terraform** v1.0 or later
3. **kubectl** installed for Kubernetes cluster access
4. Appropriate IAM permissions for creating AWS resources

## Setup Instructions

### 1. Initialize Terraform Backend

```bash
# Create S3 bucket and DynamoDB table for state management (run once)
aws s3 mb s3://healthops-terraform-state-$(aws sts get-caller-identity --query Account --output text)
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2. Initialize Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

### 3. Plan Infrastructure

```bash
# For production
terraform plan -var-file=terraform.tfvars -out=tfplan

# For staging
terraform plan -var-file=terraform.staging.tfvars -out=tfplan-staging
```

### 4. Apply Configuration

```bash
# Apply production infrastructure
terraform apply tfplan

# Apply staging infrastructure
terraform apply tfplan-staging
```

### 5. Configure kubectl

After EKS cluster is created:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name healthops-cluster
```

## Variable Overrides

You can override variables from command line:

```bash
terraform plan \
  -var="eks_node_group_desired_size=5" \
  -var="rds_instance_class=db.t3.small"
```

## Outputs

After applying Terraform, you can retrieve outputs:

```bash
# Get all outputs
terraform output

# Get specific output
terraform output eks_cluster_name
terraform output rds_endpoint
```

## State Management

### Viewing State

```bash
terraform state list
terraform state show aws_eks_cluster.main
```

### Backup

```bash
terraform state pull > terraform.state.backup
```

### Remote State

The backend is configured in `main.tf` to use S3 and DynamoDB.

## Destroying Infrastructure

⚠️ **WARNING**: This will destroy all resources

```bash
# Destroy all resources
terraform destroy -var-file=terraform.tfvars

# Destroy specific resource
terraform destroy -target=aws_eks_node_group.main
```

## Troubleshooting

### State Lock Issues

```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### Provider Issues

```bash
# Reinstall providers
rm -rf .terraform
terraform init
```

### EKS Issues

```bash
# Check cluster status
aws eks describe-cluster --name healthops-cluster

# Check node group status
aws eks describe-nodegroup --cluster-name healthops-cluster --nodegroup-name healthops-node-group
```

## Best Practices

1. Always run `terraform plan` before `apply`
2. Keep sensitive variables in `terraform.tfvars` (not committed to git)
3. Use workspaces for multiple environments
4. Enable state locking for team environments
5. Tag all resources appropriately
6. Review IAM policies regularly
7. Keep Terraform and providers updated

## Maintenance

### Upgrade Kubernetes Version

```bash
terraform apply -var="eks_cluster_version=1.29"
```

### Scale Node Group

```bash
terraform apply \
  -var="eks_node_group_desired_size=5" \
  -var="eks_node_group_max_size=10"
```

### Change RDS Instance Type

```bash
terraform apply -var="rds_instance_class=db.t3.small"
```

## Security Considerations

- RDS is not publicly accessible
- All data is encrypted at rest
- VPC uses private subnets for database
- Security groups restrict traffic appropriately
- S3 buckets have public access blocked
- Deletion protection enabled for production RDS

## Cost Optimization

- Use spot instances for non-production environments
- Scale down node groups in staging
- Use smaller RDS instance class for development
- Enable S3 lifecycle policies for old backups
- Monitor CloudWatch metrics for right-sizing
