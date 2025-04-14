
variable "aws_region"         { type = string }
variable "datasource_uid"     { type = string }
variable "folder_uid"         { type = string }

variable "lambda_name"        { type = string default = null }
variable "duration_threshold" { type = number default = 8000 }
variable "invocation_threshold" { type = number default = 10000 }

variable "certificate_name"   { type = string default = null }

variable "api_gateway_name"   { type = string default = null }
variable "stage_name"         { type = string default = null }

variable "alb_name"           { type = string default = null }

variable "dynamodb_table_name" { type = string default = null }
