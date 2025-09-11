# Environment-specific configurations for the "base" environment
# This represents the foundational infrastructure layer

locals {
  # Environment identification
  environment = "base"
  environment_type = "foundation"
  
  # Environment-specific tags
  common_tags = {
    Environment = "base"
    EnvironmentType = "foundation"
    Layer = "infrastructure"
    Criticality = "high"
    MaintenanceWindow = "sunday-02:00-04:00-utc"
  }
  
  # Environment-specific networking
  vpc_config = {
    cidr = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    
    # Base environment should have high availability
    enable_nat_gateway = true
    single_nat_gateway = false
    one_nat_gateway_per_az = true
  }
  
  # Subnet configuration for base environment
  subnet_config = {
    # Public subnets for load balancers and NAT gateways
    public_subnets = [
      "10.0.0.0/19",   # AZ-1: 8,192 IPs
      "10.0.32.0/19",  # AZ-2: 8,192 IPs
      "10.0.64.0/19"   # AZ-3: 8,192 IPs
    ]
    
    # Private subnets for applications and services
    private_subnets = [
      "10.0.96.0/19",   # AZ-1: 8,192 IPs
      "10.0.128.0/19",  # AZ-2: 8,192 IPs
      "10.0.160.0/19"   # AZ-3: 8,192 IPs
    ]
    
    # Database subnets for RDS and other managed databases
    database_subnets = [
      "10.0.192.0/19",  # AZ-1: 8,192 IPs
      "10.0.224.0/19",  # AZ-2: 8,192 IPs
      "10.1.0.0/19"     # AZ-3: 8,192 IPs
    ]
  }
  
  # Security configuration for base environment
  security_config = {
    # Enable VPC Flow Logs for security monitoring
    enable_vpc_flow_logs = true
    vpc_flow_logs_retention = 90  # days
    
    # Database subnet group settings
    create_database_subnet_group = true
    create_database_subnet_route_table = true
  }
  
  # Monitoring and logging
  monitoring_config = {
    enable_cloudwatch_logs = true
    log_retention_days = 30
    enable_detailed_monitoring = true
  }
  
  # Cost optimization settings for base environment
  cost_config = {
    # Base infrastructure should prioritize availability over cost
    enable_cost_optimization = false
    reserved_instance_coverage = "high"
  }
  
  # Backup and disaster recovery
  backup_config = {
    enable_automated_backups = true
    backup_retention_days = 35
    backup_window = "03:00-04:00"
    maintenance_window = "sun:04:00-sun:05:00"
  }
}
