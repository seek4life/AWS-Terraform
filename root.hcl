# Root Terragrunt Configuration
# This file contains the common configuration for all environments

# Configure remote state backend
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt = true
    bucket = "lumo-terraform-state-${get_aws_account_id()}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "lumo-terraform-locks"
    
    # S3 bucket tags (Terragrunt-specific)
    s3_bucket_tags = {
      Project = "lumo"
      Purpose = "terraform-state"
      ManagedBy = "terragrunt"
      Environment = "shared"
    }
    
    # DynamoDB table tags (Terragrunt-specific)
    dynamodb_table_tags = {
      Project = "lumo"
      Purpose = "terraform-locks"
      ManagedBy = "terragrunt"
      Environment = "shared"
    }
  }
}

# Generate provider configuration
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "lumo"
      ManagedBy   = "terragrunt"
      Workspace   = "$${terraform.workspace}"
    }
  }
}
EOF
}

# Generate common variables that all modules can use
generate "common_vars" {
  path = "common_vars.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
# Common variables available to all modules
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Local values for common use
locals {
  # Common naming convention
  name_prefix = "$${var.common_tags.Project}-$${var.aws_region}"
  
  # Current timestamp for unique naming
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  # Path-based environment name
  environment = basename(dirname(abspath(path.module)))
  
  # Account ID
  account_id = data.aws_caller_identity.current.account_id
}

# Data sources for common information
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
EOF
}

# Configure Terragrunt to automatically retry on known errors
retryable_errors = [
  "(?s).*Error.*RequestError.*send request.*",
  "(?s).*Error.*connection reset by peer.*",
  "(?s).*Error.*TooManyRequestsException.*",
  "(?s).*Error.*Throttling.*",
  "(?s).*Error.*RequestLimitExceeded.*"
]

# Configure inputs that will be merged with each module's inputs
inputs = {
  # Default AWS region - can be overridden at lower levels
  aws_region = "eu-central-1"
  
  # Common tags applied to all resources
  common_tags = {
    Project = "lumo"
    ManagedBy = "terragrunt"
    Repository = "AWS-Terraform"
    CreatedBy = "terragrunt"
  }
}

# Terraform hooks for common operations
terraform {
  # Run init with upgrade flag
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
    arguments = [
      "-upgrade"
    ]
  }
  
  # Use compact warnings
  extra_arguments "compact_warnings" {
    commands = [
      "plan",
      "apply",
      "destroy"
    ]
    arguments = ["-compact-warnings"]
  }
  
  # Before hook to validate Terraform formatting
  before_hook "terraform_fmt" {
    commands = ["plan", "apply"]
    execute  = ["terraform", "fmt", "-recursive", "-check"]
  }
  
  # After hook to show resource count
  after_hook "show_resources" {
    commands = ["apply"]
    execute  = ["sh", "-c", "terraform show -json | jq '.values.root_module.resources | length'"]
    run_on_error = false
  }
}

# Skip outputs when running terragrunt plan-all or apply-all
skip = false
