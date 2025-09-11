# Data source to get available AZs
data "aws_availability_zones" "available_m" {
  state = "available"
}

# VPC Module using the community module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  # Use specified number of AZs in the region
  azs = slice(data.aws_availability_zones.available_m.names, 0, var.availability_zones_count)

  # Public subnets
  public_subnets = var.public_subnets

  # Private subnets
  private_subnets       = var.private_subnets
  private_subnet_suffix = var.private_subnet_suffix_m

  # Database subnets
  database_subnets = var.database_subnets

  # Create dedicated DB subnet group
  create_database_subnet_group       = var.create_database_subnet_group
  create_database_subnet_route_table = var.create_database_subnet_route_table

  # Network configuration
  enable_nat_gateway     = var.enable_nat_gateway
  enable_vpn_gateway     = var.enable_vpn_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # DNS settings
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # VPC Flow Logs (optional)
  enable_flow_log                      = var.enable_vpc_flow_logs
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group

  # Tags
  tags = merge(var.common_tags_m, {
    Name = var.vpc_name
    Type = "vpc"
  })

  # Subnet tags - only set if subnets exist
  public_subnet_tags = length(var.public_subnets) > 0 ? merge(var.common_tags_m, var.public_subnet_tags) : {}

  private_subnet_tags = merge(var.common_tags_m, var.private_subnet_tags)

  database_subnet_tags = merge(var.common_tags_m, var.database_subnet_tags)

  # Route table tags - only set if needed
  public_route_table_tags = length(var.public_subnets) > 0 ? merge(var.common_tags_m, var.public_route_table_tags) : {}

  private_route_table_tags = merge(var.common_tags_m, var.private_route_table_tags)

  database_route_table_tags = merge(var.common_tags_m, var.database_route_table_tags)

  # Gateway tags - only set if NAT gateway enabled
  nat_gateway_tags = var.enable_nat_gateway ? merge(var.common_tags_m, var.nat_gateway_tags) : {}

  # Internet Gateway tags - only set if public subnets exist
  igw_tags = length(var.public_subnets) > 0 ? merge(var.common_tags_m, var.igw_tags) : {}
}
