
provider "aws" {
  region = var.aws_region
}

data "aws_lambda_functions" "all" {}

locals {
  matching_lambda_names = [
    for fn in data.aws_lambda_functions.all.functions :
    fn.function_name
    if startswith(fn.function_name, "adt-lambda")
  ]
}

module "lambda_alerts" {
  for_each = toset(local.matching_lambda_names)
  source               = "../../modules/alerts"
  lambda_name          = each.value
  aws_region           = var.aws_region
  datasource_uid       = var.datasource_uid
  folder_uid           = var.folder_uid
  duration_threshold   = var.lambda_duration_threshold
  invocation_threshold = var.lambda_invocation_threshold
}

module "api_gateway_alerts" {
  for_each = {
    for gw in var.api_gateways :
    "${gw.name}-${gw.stage}" => gw
  }
  source            = "../../modules/alerts"
  api_gateway_name  = each.value.name
  stage_name        = each.value.stage
  aws_region        = var.aws_region
  datasource_uid    = var.datasource_uid
  folder_uid        = var.folder_uid
}

module "alb_alerts" {
  for_each = toset(var.alb_names)
  source         = "../../modules/alerts"
  alb_name       = each.value
  aws_region     = var.aws_region
  datasource_uid = var.datasource_uid
  folder_uid     = var.folder_uid
}

module "dynamodb_alerts" {
  for_each = toset(var.dynamodb_tables)
  source                = "../../modules/alerts"
  dynamodb_table_name   = each.value
  aws_region            = var.aws_region
  datasource_uid        = var.datasource_uid
  folder_uid            = var.folder_uid
}

module "cert_expiry_alerts" {
  for_each = toset(var.acm_certificates)
  source             = "../../modules/alerts"
  certificate_name   = each.value
  aws_region         = var.aws_region
  datasource_uid     = var.datasource_uid
  folder_uid         = var.folder_uid
}
