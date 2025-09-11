# Terragrunt Structure and Configuration

This repository uses Terragrunt to manage Terraform modules across multiple environments and regions with a hierarchical configuration approach.

## Directory Structure

```
AWS-Terraform/
├── terragrunt.hcl                    # Root configuration
├── modules/                          # Reusable Terraform modules
│   └── base/                        # VPC module
│       ├── vpc.tf
│       ├── vars.tf
│       ├── output.tf
│       └── README.md
└── lumo/                            # Account-level organization
    ├── account.hcl                 # Account-wide settings
    └── aws/
        └── eu-central-1/           # Region-specific deployments
            ├── region.hcl          # Region-wide settings
            └── base/               # Environment deployment
                ├── terragrunt.hcl  # Environment-specific config
                └── env.hcl         # Environment settings
```

## Configuration Hierarchy

Terragrunt uses a hierarchical configuration system where settings are inherited and can be overridden at each level:

### 1. Root Level (`terragrunt.hcl`)

- Remote state configuration (S3 + DynamoDB)
- Provider generation
- Common variables and hooks
- Default tags and inputs

### 2. Account Level (`lumo/account.hcl`)

- Account-specific settings
- Common tags for the account
- Security and compliance settings
- Cost optimization defaults

### 3. Region Level (`lumo/aws/eu-central-1/region.hcl`)

- Region-specific configurations
- CIDR allocations per region
- Availability zones
- Regional networking settings

### 4. Environment Level (`lumo/aws/eu-central-1/base/env.hcl`)

- Environment-specific settings
- Security configurations
- Monitoring and backup settings
- Environment-specific tags

### 5. Component Level (`lumo/aws/eu-central-1/base/terragrunt.hcl`)

- Module source reference
- Input variables and values
- Dependencies
- Component-specific configurations

## Usage

### Initialize and Deploy

```bash
# Navigate to the component directory
cd lumo/aws/eu-central-1/base

# Initialize Terragrunt (will also run terraform init)
terragrunt init

# Plan the infrastructure
terragrunt plan

# Apply the infrastructure
terragrunt apply

# Destroy the infrastructure
terragrunt destroy
```

### Working with Multiple Environments

```bash
# Deploy all environments in a region
cd lumo/aws/eu-central-1
terragrunt run-all plan
terragrunt run-all apply

# Deploy everything in the account
cd lumo
terragrunt run-all plan
terragrunt run-all apply
```

### State Management

Remote state is automatically configured and stored in:

- **S3 Bucket**: `lumo-terraform-state-{account-id}`
- **DynamoDB Table**: `lumo-terraform-locks`
- **State Key**: `{path-relative-to-include}/terraform.tfstate`

### Variable Override Precedence

Values are merged in this order (last wins):

1. Root `terragrunt.hcl` inputs
2. Account `account.hcl` locals
3. Region `region.hcl` locals
4. Environment `env.hcl` locals
5. Component `terragrunt.hcl` inputs

## Configuration Examples

### Adding a New Environment

1. Create the directory structure:

```bash
mkdir -p lumo/aws/eu-central-1/dev
```

2. Create `terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders()
}

include "region" {
  path = find_in_parent_folders("region.hcl")
}

terraform {
  source = "../../../../../modules/base"
}

inputs = {
  vpc_name = "lumo-${local.region_vars.locals.aws_region}-dev-vpc"
  vpc_cidr = local.region_vars.locals.environment_cidrs.dev

  # Override settings for dev environment
  single_nat_gateway = true  # Cost savings for dev
  enable_vpc_flow_logs = false

  common_tags = merge(
    local.region_vars.locals.common_tags,
    {
      Environment = "dev"
      CostOptimized = "true"
    }
  )
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}
```

### Adding a New Region

1. Create the directory structure:

```bash
mkdir -p lumo/aws/us-west-2
```

2. Create `region.hcl`:

```hcl
locals {
  aws_region = "us-west-2"

  environment_cidrs = {
    base = "10.10.0.0/16"  # Different CIDR for new region
    dev = "10.11.0.0/16"
    staging = "10.12.0.0/16"
    prod = "10.13.0.0/16"
  }

  common_tags = {
    Region = "us-west-2"
    RegionCode = "usw2"
    Timezone = "America/Los_Angeles"
  }
}
```

## Best Practices

1. **Keep modules DRY**: Store reusable logic in `modules/`
2. **Use consistent naming**: Follow the pattern `{project}-{region}-{environment}-{component}`
3. **Tag everything**: Use the hierarchical tag system for cost allocation and management
4. **Environment isolation**: Use separate CIDR blocks per environment
5. **State isolation**: Each component has its own state file
6. **Version control**: Pin module versions in production environments

## Troubleshooting

### Common Commands

```bash
# Check what Terragrunt will do
terragrunt plan-all --terragrunt-log-level debug

# Show dependency graph
terragrunt graph-dependencies

# Validate all configurations
terragrunt validate-all

# Show generated backend configuration
terragrunt terragrunt-info
```

### State Issues

```bash
# Refresh state
terragrunt refresh

# Import existing resource
terragrunt import aws_vpc.main vpc-xxxxxxxxx

# Unlock state (if locked)
terragrunt force-unlock LOCK_ID
```
