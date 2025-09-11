# Region-specific configurations for eu-central-1
locals {
  # AWS Region
  aws_region = "eu-central-1"
  
  # Region-specific common tags
  common_tags = {
    Region = "eu-central-1"
    RegionCode = "euc1"
    Timezone = "Europe/Berlin"
  }
  
  # Region-specific networking
  region_cidr_base = "10.0.0.0/8"  # Overall CIDR space for this region
  
  # Environment-specific CIDR allocations
  environment_cidrs = {
    base = "10.0.0.0/16"    # Base/Foundation: 10.0.0.0 - 10.0.255.255
    dev = "10.1.0.0/16"     # Development: 10.1.0.0 - 10.1.255.255
    staging = "10.2.0.0/16" # Staging: 10.2.0.0 - 10.2.255.255
    prod = "10.3.0.0/16"    # Production: 10.3.0.0 - 10.3.255.255
  }
  
  # Availability Zones in eu-central-1
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  
  # Region-specific configuration
  nat_gateway_configuration = {
    # For eu-central-1, use one NAT gateway per AZ for high availability
    single_nat_gateway = false
    one_nat_gateway_per_az = true
  }
  
  # VPC Flow Logs configuration per region
  vpc_flow_logs = {
    enable = true  # Enable in eu-central-1 for compliance
    retention_days = 30
    log_destination_type = "cloud-watch-logs"
  }
  
  # DNS settings
  dns_configuration = {
    enable_dns_hostnames = true
    enable_dns_support = true
    enable_dns_resolution = true
  }
}
