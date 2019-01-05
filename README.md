# AWS API Gateway Terraform Module

Convenience module for AWS API Gateway

## Usage

```tf
module "users-api-gateway" {
  source       = "assemble-inc/gateway/api"
  gateway_name = "users"
  domain_name  = "example.com"
  stage_name   = "production"
}
```

## Inputs

- **gateway_name**: Gateway name
- **domain_name**: Domain
- **stage_name**: Stage name
- **tags**: Tags map

## Outputs

- **gateway_id**: Gateway Id
- **gateway_root_resource_id**: Root resource id
- **getaway_fpdn**: Gateway FQDN
