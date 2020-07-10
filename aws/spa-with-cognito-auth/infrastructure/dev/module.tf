module "dev" {
  source = "../common"

  app = "sample"
  env = "dev"
  spa_origin_id = "dev-sample"
  spa_output = "../../build"
}