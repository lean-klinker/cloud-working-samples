# Terraform Infrastructure

Terraform is a used to automate infrastructure creation, modification, and deletion.
Terraform code for this application is in the [infrastructure](./infrastructure) directory.

## AWS Services
- [Cognito](https://aws.amazon.com/cognito/)
- [CloudFront](https://aws.amazon.com/cloudfront/)
- [S3](https://aws.amazon.com/s3/)

## Terraform Code Organization

The [dev](./infrastructure/dev) and [common](./infrastructure/common) folders in the [infrastructure](./infrastructure) 
directory are terraform [modules](https://www.terraform.io/docs/configuration/modules.html). 

### Common

The [common](./infrastructure/common) module contains the code that represents the definition of 
the infrastructure we want terraform to maintain. All .tf files in this directory are part of the common module. 

This module defines the AWS services that will be used by each environment. It also defines specific variables that
are used to generate the names and settings for the module. The variables for [common](./infrastructure/common) can be 
found in the [variables.tf](./infrastructure/common/variables.tf) file. You can learn more about terraform variables 
[here](https://www.terraform.io/docs/configuration/variables.html).

### Dev

The [dev](./infrastructure/dev) module uses the [common](./infrastructure/common) module as its source. This is similar 
to saying that the dev module inherits/derives from the [common](./infrastructure/common) module. 

The key points in the [dev](./infrastructure/dev) folder are:
- [main.tf](./infrastructure/dev/main.tf)
  - This file specifies the values to pass to the [common](./infrastructure/common) module. These values should be specific to the dev environment.
- [backend.tf](./infrastructure/dev/backend.tf)
  - This file specifies that we want to store our terraform state in a s3 bucket. You can read more about Terraform 
  state [here](https://www.terraform.io/docs/state/index.html)

### How could I add prod?

The process for adding a "prod" would be the following steps:

1. Create a folder named "prod" to ./infrastructure
1. Add a file called "main.tf"
  1. Add a module block to "main.tf"
  1. Set the source to "../common"
  1. Set the env to "prod"
1. Copy [backend.tf](./infrastructure/dev/backend.tf) to "prod" directory
1. DONE!