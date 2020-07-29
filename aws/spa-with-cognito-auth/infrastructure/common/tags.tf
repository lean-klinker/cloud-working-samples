locals {
  // Here we are specifying common tags that we want to place on resources. This can aid in finding
  // parts of the infrastructure that are related.
  tags = merge(
    var.tags,
    {
      Application = var.app
      Environment = var.env
    }
  )
}