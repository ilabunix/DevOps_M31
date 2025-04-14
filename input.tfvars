
aws_region     = "us-gov-east-1"
datasource_uid = "cloudwatch"
folder_uid     = "aws-alerts"

lambda_duration_threshold   = 8000
lambda_invocation_threshold = 10000

api_gateways = [
  { name = "adt-api", stage = "dev" },
  { name = "auth-api", stage = "dev" }
]

alb_names = [
  "app/adt-alb-dev/abc123def456",
  "app/internal-auth-alb-dev/xyz789ghi321"
]

dynamodb_tables = [
  "users-table",
  "orders-table"
]

acm_certificates = [
  "api.example.com",
  "internal.service.local"
]
