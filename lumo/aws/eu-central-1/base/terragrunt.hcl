# Include all settings from the root configuration file
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include region-specific configurations
include "region" {
  path = find_in_parent_folders("region.hcl")
}

# Include account-specific configurations (if exists)
include "account" {
  path = find_in_parent_folders("account.hcl")
  expose = true
}

# Terragrunt will copy the Terraform configurations from this location
terraform {
  source = "../../../../modules/base"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # VPC Configuration
  vpc_name = "lumo-${local.region_vars.locals.aws_region}-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  # Number of AZs to use
  availability_zones_count = 3
  
  # Subnet Configuration - /19 subnets (8,192 IPs each)
  # No public subnets - only private and database subnets
  public_subnets = []
  
  private_subnets = [
    "10.0.0.0/19",    # AZ-1: 10.0.0.0 - 10.0.31.255
    "10.0.32.0/19",   # AZ-2: 10.0.32.0 - 10.0.63.255
    "10.0.64.0/19"    # AZ-3: 10.0.64.0 - 10.0.95.255
  ]
  
  database_subnets = [
    "10.0.96.0/19",   # AZ-1: 10.0.96.0 - 10.0.127.255
    "10.0.128.0/19",  # AZ-2: 10.0.128.0 - 10.0.159.255
    "10.0.160.0/19"   # AZ-3: 10.0.160.0 - 10.0.191.255
  ]
  
  # Network Features
  # NAT gateway disabled since no public subnets available
  enable_nat_gateway = false
  enable_vpn_gateway = false
  single_nat_gateway = false
  one_nat_gateway_per_az = false
  
  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support = true
  
  # Database Subnet Configuration
  create_database_subnet_group = true
  create_database_subnet_route_table = true
  
  # VPC Flow Logs
  enable_vpc_flow_logs = false
  create_flow_log_cloudwatch_iam_role = false
  create_flow_log_cloudwatch_log_group = false
  
  # Common Tags
  common_tags = merge(
    try(local.region_vars.locals.common_tags, {}),
    try(local.account_vars.locals.common_tags, {}),
    {
      Environment = "base"
      Component   = "networking"
      Layer       = "foundation"
    }
  )
  
  # Subnet Tags
  # No public subnets, so no public subnet tags needed
  private_subnet_tags = {
    Name = "private_subnet"
    Type = "private"
    "kubernetes.io/role/internal-elb" = "1"
    Tier = "application"
  }
  
  database_subnet_tags = {
    Name = "database_subnet"
    Type = "database"
    Tier = "data"
  }
  
  # Route Table Tags
  # No public route table tags needed since no public subnets
  private_route_table_tags = {
    Name = "private-rt"
    Type = "private-rt"
    Purpose = "isolated-private"
  }
  
  database_route_table_tags = {
    NameL = "database-rt"
    Type = "database-rt"
    Purpose = "isolated-database"
  }
  
  # No gateway tags needed since no public subnets, NAT gateways, or internet gateway
  
  # AWS Region (from region configuration)
  aws_region = try(local.region_vars.locals.aws_region, "eu-central-1")
}

# Local variables to read from parent configurations
locals {
  # Read region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Read account-level variables (if exists)
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

# Dependencies - if you have other infrastructure this depends on
# dependencies {
#   paths = ["../route53", "../network"]
# }
