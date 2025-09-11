# VPC Configuration: No Public Subnets

This VPC configuration is designed to operate **without public subnets**, creating a more secure, isolated network architecture.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                           VPC: 10.0.0.0/16                         │
├─────────────────────────────────────────────────────────────────────┤
│                        Private Subnets Only                        │
│                                                                     │
│  ┌─────────────────────┬─────────────────────┬─────────────────────┐ │
│  │    AZ-1 Private     │    AZ-2 Private     │    AZ-3 Private     │ │
│  │   10.0.0.0/19      │   10.0.32.0/19     │   10.0.64.0/19     │ │
│  │   (Application)     │   (Application)     │   (Application)     │ │
│  └─────────────────────┴─────────────────────┴─────────────────────┘ │
│                                                                     │
│  ┌─────────────────────┬─────────────────────┬─────────────────────┐ │
│  │   AZ-1 Database     │   AZ-2 Database     │   AZ-3 Database     │ │
│  │   10.0.96.0/19     │   10.0.128.0/19    │   10.0.160.0/19    │ │
│  │      (RDS)          │      (RDS)          │      (RDS)          │ │
│  └─────────────────────┴─────────────────────┴─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## Configuration Details

### What's Included

- ✅ **Private Subnets**: 3x /19 subnets across AZs for applications
- ✅ **Database Subnets**: 3x /19 subnets across AZs for databases
- ✅ **Database Subnet Group**: Dedicated RDS subnet group
- ✅ **VPC DNS**: DNS hostnames and resolution enabled
- ✅ **Isolated Routing**: Separate route tables for private and database subnets

### What's Excluded

- ❌ **Public Subnets**: No public subnets created
- ❌ **Internet Gateway**: Not attached (no public internet access)
- ❌ **NAT Gateways**: Not created (require public subnets)
- ❌ **Public Load Balancers**: Cannot be deployed

## Network Connectivity

### Internal Communication

- ✅ **Private-to-Private**: Full communication within private subnets
- ✅ **Private-to-Database**: Application servers can access databases
- ✅ **Database-to-Database**: Database replication and clustering
- ✅ **DNS Resolution**: Internal AWS service discovery

### External Communication

- ❌ **Outbound Internet**: No direct internet access from private subnets
- ❌ **Inbound Internet**: No internet-facing services
- ⚠️ **AWS Services**: Limited to VPC endpoints only

## Use Cases

This configuration is ideal for:

1. **Highly Secure Applications**

   - Internal-only applications
   - Compliance-required isolation
   - Air-gapped environments

2. **Backend Services**

   - Database tiers
   - Internal APIs
   - Processing services

3. **Hybrid Cloud Architectures**
   - Connected via VPN or Direct Connect
   - On-premises connectivity required
   - Private network extensions

## Connectivity Options

To enable external connectivity, consider:

### Option 1: VPC Endpoints

```hcl
# Add VPC endpoints for AWS services
vpc_endpoints = {
  s3 = {
    service = "s3"
    route_table_ids = [private_route_table_ids]
  }

  ssm = {
    service = "ssm"
    subnet_ids = [private_subnet_ids]
  }
}
```

### Option 2: Transit Gateway

```hcl
# Connect to shared networking VPC
transit_gateway_id = "tgw-xxxxxxxxx"
transit_gateway_routes = ["0.0.0.0/0"]
```

### Option 3: VPN Gateway

```hcl
# Enable VPN gateway in configuration
enable_vpn_gateway = true
```

### Option 4: NAT Instance (Alternative)

- Deploy custom NAT instance in a separate public subnet
- Route private subnet traffic through NAT instance
- More complex but provides outbound internet access

## Security Benefits

1. **Attack Surface Reduction**: No internet-facing entry points
2. **Data Isolation**: All data stays within private networks
3. **Compliance**: Meets strict regulatory requirements
4. **Network Segmentation**: Clear separation between tiers

## Operational Considerations

### Advantages

- Enhanced security posture
- Simplified security group rules
- No NAT gateway costs
- Predictable traffic patterns

### Limitations

- No outbound internet access for updates
- Requires alternative connectivity methods
- More complex deployment pipelines
- Limited AWS service access without endpoints

## Migration Path

To add public subnets later:

1. Update `terragrunt.hcl`:

```hcl
public_subnets = [
  "10.0.192.0/19",  # Add new CIDR ranges
  "10.0.224.0/19",
  "10.1.0.0/19"
]
enable_nat_gateway = true
```

2. Update module variables as needed
3. Apply changes with Terragrunt

## Cost Implications

**Savings:**

- No NAT Gateway charges (~$45-135/month per gateway)
- No NAT Gateway data transfer costs
- Reduced Elastic IP costs

**Additional Costs:**

- VPC Endpoints (if needed): ~$7-22/month per endpoint
- VPN Gateway (if used): ~$36/month
- Transit Gateway (if used): ~$36/month + data processing

## Monitoring and Troubleshooting

### VPC Flow Logs

```hcl
enable_vpc_flow_logs = true
```

### CloudWatch Metrics

- Monitor VPC endpoint usage
- Track internal traffic patterns
- Monitor database connectivity

### Common Issues

1. **Service Access**: Use VPC endpoints for AWS services
2. **Software Updates**: Use Systems Manager or private repos
3. **Container Images**: Use ECR with VPC endpoints
4. **DNS Resolution**: Verify Route 53 resolver configuration
