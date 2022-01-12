[![CircleCI](https://circleci.com/gh/animaldna/catalog-api-tf-public/tree/master.svg?style=shield&circle-token=be30bbdc1c9a1555367c5736e490eac00aa7f37e)](https://circleci.com/gh/animaldna/catalog-api-tf-public/tree/master)

# Catalog API Infrastructure (Protected)
This is a Terraform project to manage the infrastructure for a [demo catalog API.](https://github.com/animaldna/catalog-api)

This version runs ECS from public subnets and relies on an ALB + security groups to control access. It's less secure, but cheaper than running a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) (or NAT instance).

The private version is [available in this repo ]()(coming soon).

![Public ECS architecture](./catalog_api_infra_public.jpg)

## Additional Info
This infrastructure isn't fully managed by Terraform. Managing backend config resources (S3 + DynamoDB) in the same TF project proved problematic, so those were created manually and are passed to TF.

The Route 53 hosted zone was also created outside of Terraform. Most domains are already registered and setup when a new service is created, as was the case with mine.

**This project is meant to manage infrastructure only, NOT deployment.** 

The `image` variable is technically meant to be a placeholder, as a deploy script handles task definition updates outside of Terraform. [You can read more about this setup here ]()(coming soon). The default right now is a public sleep container. Pass something meaningful when launching, otherwise you'll get 503 errors from the load balancer.


## CI/CD Pipeline
TBD

## Requirements
- Terraform v1.1.2
- S3 bucket to store state files
- DynamoDB table for state locking
- Appropriate IAM permissions
- Route 53 hosted zone
- Certificate Manager SSL cert for domain (temporary)

## Usage
Create a backend config file:
```
bucket         = "your-state-bucket"
key            = "your-key-here/terraform.tfstate"
region         = "your-aws-region"
encrypt        = true||false
dynamodb_table = "your-state-lock-table-name"
```

Initialize Terraform with your backend config and variables. I use .tfvars files when working locally and var flags when running from a CI pipeline.

```sh
terraform init -backend-config="dev.s3.tfbackend" -var-file="dev.tfvars"
```

Validate your project:

```sh
terraform validate
```

Apply (or plan if you'd like to review first):
```sh
terraform apply|plan -var-file="dev.tfvars"
```

Destroy resources:
```sh
terraform destroy -var-file"dev.tfvars"
```


## TODOs
### CircleCI
- [x] Conditional CircleCI jobs - don't need stage env for small changes
- [ ] Pull last stable image to use in task def for stage builds
- [ ] Optional job for stage branch only
- [ ] Optional job for dev branch only
- [ ] Slack notifications for build fail/success
- [ ] Slack approvals
- [ ] TF plans as artifacts?
- [ ] Additional TF testing needed?
- [ ] Add CI workflow diagram
### Terraform
- [x] Container logging (ecs)
- [x] Auto scaling
- [x] Sort out separation of environments and state management
- [ ] Load testing
- [ ] Dynamic ports (ecs)
- [ ] Dynamic ACM cert
- [ ] Add safe IPs to SGs for SSH access (sgs)
- [ ] Restrict ECS roles (iam)
- [ ] Get NACL template working (vpc)

Articles of note: 
- [Terraform Dynamic Subnets](https://medium.com/prodopsio/terraform-aws-dynamic-subnets-455619dd1977)
- [Terraform cidrsubnet function](https://www.terraform.io/language/functions/cidrsubnet)
- [Terraform cidrsubnet deconstructed](http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/)

## Author
Chloe Boylan

## License
Copyright © 2021 Chloe Boylan.
This project is MIT licensed.
