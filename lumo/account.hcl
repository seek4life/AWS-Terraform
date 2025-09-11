# Account-level configurations for the lumo project
locals {
  # Account information
  account_name = "lumo"
  account_id = get_aws_account_id()  # Terragrunt will fetch this automatically
  
  # Common tags applied to all resources in this account
  common_tags = {
    Project = "lumo"
    ManagedBy = "terragrunt"
    Account = "lumo"
    Owner = "platform-team"
    CostCenter = "engineering"
    Environment = "multi"  # This account hosts multiple environments
  }
  
  # Default remote state configuration
  remote_state = {
    backend = "s3"
    config = {
      encrypt = true
      bucket = "lumo-terraform-state-${get_aws_account_id()}"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = "eu-central-1"
      dynamodb_table = "lumo-terraform-locks"
      
      # Enable versioning and lifecycle
      s3_bucket_tags = {
        Project = "lumo"
        Purpose = "terraform-state"
        ManagedBy = "terragrunt"
      }
    }
  }
  
  # Default provider configuration
  default_provider_config = {
    region = "eu-central-1"
    
    default_tags = {
      tags = {
        Project = "lumo"
        ManagedBy = "terragrunt"
        Account = get_aws_account_id()
      }
    }
  }
  
  # Security and compliance settings
  security_config = {
    # Require encrypted storage
    encrypt_storage = true
    
    # Enable detailed monitoring
    enable_detailed_monitoring = true
    
    # VPC Flow Logs retention
    vpc_flow_logs_retention = 90
  }
  
  # Cost optimization settings
  cost_optimization = {
    # Default instance types for different environments
    default_instance_types = {
      dev = "t3.micro"
      staging = "t3.micro"
      prod = "t3.micro"
    }
    
    # Auto-scaling defaults
    enable_auto_scaling = true
    
    # Backup retention
    backup_retention_days = 30
  }
}
