# AWS VPC Terraform Configuration

This Terraform configuration creates a robust, production-ready VPC using the official AWS VPC community module with fully configurable parameters.

## Architecture Overview

The VPC includes:

- **Public Subnets**: For load balancers and NAT gateways
- **Private Subnets**: For application servers (with outbound internet via NAT)
- **Database Subnets**: For RDS and other database services (isolated)
- **Multi-AZ Setup**: Spans multiple availability zones for high availability
- **NAT Gateways**: One per AZ for high availability (configurable)
- **Internet Gateway**: For public subnet internet access

## Default Network Design

- **VPC CIDR**: `10.0.0.0/16` (65,536 IPs)
- **Subnet Size**: `/19` per subnet (8,192 IPs each)
- **Availability Zones**: 3 (configurable)

### Default CIDR Allocation

```
Public Subnets:
├── AZ-1: 10.0.0.0/19   (10.0.0.0 - 10.0.31.255)
├── AZ-2: 10.0.32.0/19  (10.0.32.0 - 10.0.63.255)
└── AZ-3: 10.0.64.0/19  (10.0.64.0 - 10.0.95.255)

Private Subnets:
├── AZ-1: 10.0.96.0/19  (10.0.96.0 - 10.0.127.255)
├── AZ-2: 10.0.128.0/19 (10.0.128.0 - 10.0.159.255)
└── AZ-3: 10.0.160.0/19 (10.0.160.0 - 10.0.191.255)

Database Subnets:
├── AZ-1: 10.0.192.0/19 (10.0.192.0 - 10.0.223.255)
├── AZ-2: 10.0.224.0/19 (10.0.224.0 - 10.0.255.255)
└── AZ-3: 10.1.0.0/19   (10.1.0.0 - 10.1.31.255)
```

## Usage

### 1. Quick Start (Use Defaults)

```bash
terraform init
terraform plan
terraform apply
```

### 2. Custom Configuration

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your custom values
vim terraform.tfvars

# Deploy
terraform init
terraform plan
terraform apply
```

### 3. Example Custom Configuration

```hcl
vpc_name = "my-production-vpc"
vpc_cidr = "10.0.0.0/16"
availability_zones_count = 2

# Custom subnet CIDRs
public_subnets = ["10.0.0.0/20", "10.0.16.0/20"]
private_subnets = ["10.0.32.0/20", "10.0.48.0/20"]
database_subnets = ["10.0.64.0/20", "10.0.80.0/20"]

# Cost optimization
single_nat_gateway = true
one_nat_gateway_per_az = false

common_tags = {
  Environment = "production"
  Project     = "my-app"
  Owner       = "team-platform"
}
```

## Key Configuration Variables

| Variable                   | Description                           | Default                   |
| -------------------------- | ------------------------------------- | ------------------------- |
| `vpc_name`                 | Name for the VPC                      | `"lumo-eu-central-1-vpc"` |
| `vpc_cidr`                 | VPC CIDR block                        | `"10.0.0.0/16"`           |
| `availability_zones_count` | Number of AZs to use                  | `3`                       |
| `public_subnets`           | Public subnet CIDRs                   | See defaults              |
| `private_subnets`          | Private subnet CIDRs                  | See defaults              |
| `database_subnets`         | Database subnet CIDRs                 | See defaults              |
| `enable_nat_gateway`       | Enable NAT gateways                   | `true`                    |
| `single_nat_gateway`       | Use single NAT gateway (cost savings) | `false`                   |
| `enable_vpc_flow_logs`     | Enable VPC Flow Logs                  | `false`                   |

## Cost Considerations

### High Availability (Default)

- One NAT Gateway per AZ
- Higher cost but better availability
- Recommended for production

### Cost Optimized

```hcl
single_nat_gateway = true
one_nat_gateway_per_az = false
```

- Single NAT Gateway for all private subnets
- Lower cost but single point of failure
- Suitable for development/staging

## Outputs

The module provides comprehensive outputs including:

- VPC ID and CIDR
- All subnet IDs and CIDRs
- Route table IDs
- Gateway IDs
- Database subnet group
- Available AZs

See `output.tf` for the complete list.

## Module Dependencies

This configuration uses the official AWS VPC module:

```hcl
source = "terraform-aws-modules/vpc/aws"
version = "~> 5.0"
```

## Tags

All resources are tagged with:

- Common tags (configurable via `common_tags`)
- Resource-specific tags
- Kubernetes compatibility tags (for EKS)

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Appropriate AWS permissions for VPC resources

## Validation

The configuration includes validation rules:

- Availability zones count must be between 2 and 6
- Subnet CIDR lists should match the AZ count

## Next Steps

After deploying the VPC, you can:

1. Deploy EKS clusters in private subnets
2. Create RDS instances in database subnets
3. Set up Application Load Balancers in public subnets
4. Configure VPC endpoints for AWS services
