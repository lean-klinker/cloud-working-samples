variable "region" {
  type = string
}

// This file defines the values that should be used to create the development environment.
module "dev" {
  // This points the dev module at the common folder. The dev module provides variables to the common module.
  source = "../common"

  env = "dev"
  region = var.region
}

// When you need to know the generated values for resources you can specify them as outputs to be able to access
// them once the deployment is done. You can use the `terraform output` command to get output values.
// See Terraform docs for more info on the `output` command: https://www.terraform.io/docs/commands/output.html
output "spa_client_id" {
  value = module.dev.spa_client_id
}

output "spa_cloud_front_distribution_id" {
  value = module.dev.spa_cloud_front_distribution_id
}