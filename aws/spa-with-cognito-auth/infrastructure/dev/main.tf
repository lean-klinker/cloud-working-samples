variable "region" {
  type = string
}

module "dev" {
  source = "../common"

  env = "dev"
  region = var.region
}

output "spa_client_id" {
  value = module.dev.spa_client_id
}

output "spa_cloud_front_distribution_id" {
  value = module.dev.spa_cloud_front_distribution_id
}