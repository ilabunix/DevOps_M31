
variable "aws_region"         { type = string }
variable "datasource_uid"     { type = string }
variable "folder_uid"         { type = string }
variable "deploy_env"         { type = string }

variable "lambda_name"        { type = string default = null }
variable "duration_threshold" { type = number default = 8000 }
variable "invocation_threshold" { type = number default = 10000 }

variable "certificate_name"   { type = string default = null }
variable "acm_expiry_thresholds" {
  type    = list(number)
  default = [60, 30, 15, 7, 1]
}

variable "api_gateway_name"   { type = string default = null }
variable "stage_name"         { type = string default = null }
variable "apigw_latency_threshold" { type = number default = 1000 }

variable "alb_name"           { type = string default = null }
variable "alb_tls_error_threshold" { type = number default = 10 }

variable "dynamodb_table_name" { type = string default = null }
variable "dynamodb_replication_latency_threshold" { type = number default = 30 }
