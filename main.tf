
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
  duration_threshold   = var.duration_threshold
  invocation_threshold = var.invocation_threshold
  deploy_env           = var.deploy_env
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
  apigw_latency_threshold = var.apigw_latency_threshold
  deploy_env        = var.deploy_env
}

module "alb_alerts" {
  for_each = toset(var.alb_names)
  source         = "../../modules/alerts"
  alb_name       = each.value
  aws_region     = var.aws_region
  datasource_uid = var.datasource_uid
  folder_uid     = var.folder_uid
  alb_tls_error_threshold = var.alb_tls_error_threshold
  deploy_env     = var.deploy_env
}

module "dynamodb_alerts" {
  for_each = toset(var.dynamodb_tables)
  source                      = "../../modules/alerts"
  dynamodb_table_name         = each.value
  aws_region                  = var.aws_region
  datasource_uid              = var.datasource_uid
  folder_uid                  = var.folder_uid
  dynamodb_replication_latency_threshold = var.dynamodb_replication_latency_threshold
  deploy_env                  = var.deploy_env
}

module "cert_expiry_alerts" {
  for_each = toset(var.acm_certificates)
  source             = "../../modules/alerts"
  certificate_name   = each.value
  aws_region         = var.aws_region
  datasource_uid     = var.datasource_uid
  folder_uid         = var.folder_uid
  acm_expiry_thresholds = var.acm_expiry_thresholds
  deploy_env         = var.deploy_env
}
