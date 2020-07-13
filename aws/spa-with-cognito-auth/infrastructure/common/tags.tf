locals {
  tags = merge(
    var.tags,
    {
      Application = var.app
      Environment = var.env
    }
  )
}