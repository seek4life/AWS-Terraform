# VPC Configuration Variables
variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "lumo-eu-central-1-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
  validation {
    condition     = var.availability_zones_count >= 2 && var.availability_zones_count <= 6
    error_message = "The availability_zones_count must be between 2 and 6."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks. Leave empty [] for no public subnets."
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default = [
    "10.0.0.0/19",  # AZ-1: 10.0.0.0 - 10.0.31.255
    "10.0.32.0/19", # AZ-2: 10.0.32.0 - 10.0.63.255
    "10.0.64.0/19"  # AZ-3: 10.0.64.0 - 10.0.95.255
  ]
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default = [
    "10.0.96.0/19",  # AZ-1: 10.0.96.0 - 10.0.127.255
    "10.0.128.0/19", # AZ-2: 10.0.128.0 - 10.0.159.255
    "10.0.160.0/19"  # AZ-3: 10.0.160.0 - 10.0.191.255
  ]
}

variable "create_database_subnet_group" {
  description = "Create dedicated database subnet group"
  type        = bool
  default     = true
}

variable "create_database_subnet_route_table" {
  description = "Create dedicated database subnet route table"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for private subnets outbound connectivity"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway for the VPC"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT Gateway across all private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per availability zone"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Create IAM role for VPC Flow Logs to CloudWatch"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Create CloudWatch Log Group for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "common_tags_m" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "lumo"
    Region      = "eu-central-1"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets (only used if public subnets exist)"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default = {
    Type                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

variable "database_subnet_tags" {
  description = "Additional tags for database subnets"
  type        = map(string)
  default = {
    Type = "database"
  }
}

variable "public_route_table_tags" {
  description = "Additional tags for public route tables (only used if public subnets exist)"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for private route tables"
  type        = map(string)
  default = {
    Type = "private-rt"
  }
}

variable "database_route_table_tags" {
  description = "Additional tags for database route tables"
  type        = map(string)
  default = {
    Type = "database-rt"
  }
}

variable "nat_gateway_tags" {
  description = "Additional tags for NAT Gateways (only used if NAT gateway enabled)"
  type        = map(string)
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for Internet Gateway (only used if public subnets exist)"
  type        = map(string)
  default     = {}
}

# Optional: AWS Region variable
variable "aws_region_m" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "private_subnet_suffix_m" {
  description = "AWS region for resources"
  type        = string
  default     = "private_subnet"
}