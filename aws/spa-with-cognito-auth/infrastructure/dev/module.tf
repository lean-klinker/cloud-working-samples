module "dev" {
  source = "../common"

  app = "sample"
  env = "dev"
  spa_origin_id = "dev-sample"
  spa_output = "../../build"
}

output "spa_client_id" {
  value = module.dev.spa_client_id
}

output "spa_cloud_front_distribution_id" {
  value = module.dev.spa_cloud_front_distribution_id
}