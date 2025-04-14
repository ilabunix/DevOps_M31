
##############################
# ALERT MODULE - ALL SERVICES
##############################

##############################
# LAMBDA ALERTS
##############################
resource "grafana_rule_group" "lambda_alerts" {
  count      = var.lambda_name != null ? 1 : 0
  name       = "${var.lambda_name} Lambda Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  rule {
    name = "Lambda Errors - ${var.lambda_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/Lambda",
        metricName = "Errors",
        dimensions = { FunctionName = var.lambda_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [1] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "Lambda ${var.lambda_name} is throwing errors." }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  rule {
    name = "Lambda Throttles - ${var.lambda_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/Lambda",
        metricName = "Throttles",
        dimensions = { FunctionName = var.lambda_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [1] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "Lambda ${var.lambda_name} is being throttled." }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  rule {
    name = "Lambda Duration - ${var.lambda_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/Lambda",
        metricName = "Duration",
        dimensions = { FunctionName = var.lambda_name },
        statistic = "Average",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [var.duration_threshold] }
    labels = { severity = "high" }
      email    = var.deploy_env
    annotations = { summary = "Lambda ${var.lambda_name} duration is high." }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  rule {
    name = "Lambda Invocations Spike - ${var.lambda_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/Lambda",
        metricName = "Invocations",
        dimensions = { FunctionName = var.lambda_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [var.invocation_threshold] }
    labels = { severity = "medium" }
      email    = var.deploy_env
    annotations = { summary = "Spike in invocations for Lambda ${var.lambda_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }
}
##############################
# ACM CERTIFICATE ALERTS
##############################
resource "grafana_rule_group" "acm_alerts" {
  count      = var.certificate_name != null ? 1 : 0
  name       = "${var.certificate_name} ACM Certificate Alerts"
  folder_uid = var.folder_uid
  interval   = "1h"

  # Add dynamic rules for 60, 30, 15, 7, 1 days to expiry
}
##############################
# API GATEWAY ALERTS
##############################
resource "grafana_rule_group" "apigw_alerts" {
  count      = var.api_gateway_name != null ? 1 : 0
  name       = "${var.api_gateway_name}-${var.stage_name} API Gateway Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  # 1. 5XX Errors
  rule {
    name = "API Gateway 5XX - ${var.api_gateway_name}-${var.stage_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApiGateway",
        metricName = "5XXError",
        dimensions = {
          ApiName = var.api_gateway_name,
          Stage = var.stage_name
        },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [10] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "High 5XX errors on API ${var.api_gateway_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 2. 4XX Errors
  rule {
    name = "API Gateway 4XX - ${var.api_gateway_name}-${var.stage_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApiGateway",
        metricName = "4XXError",
        dimensions = {
          ApiName = var.api_gateway_name,
          Stage = var.stage_name
        },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [50] }
    labels = { severity = "high" }
      email    = var.deploy_env
    annotations = { summary = "High 4XX errors on API ${var.api_gateway_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 3. Latency
  rule {
    name = "API Latency - ${var.api_gateway_name}-${var.stage_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApiGateway",
        metricName = "Latency",
        dimensions = {
          ApiName = var.api_gateway_name,
          Stage = var.stage_name
        },
        statistic = "Average",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [1000] }
    labels = { severity = "high" }
      email    = var.deploy_env
    annotations = { summary = "Latency > 1000ms on API ${var.api_gateway_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 4. Integration Latency
  rule {
    name = "Integration Latency - ${var.api_gateway_name}-${var.stage_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApiGateway",
        metricName = "IntegrationLatency",
        dimensions = {
          ApiName = var.api_gateway_name,
          Stage = var.stage_name
        },
        statistic = "Average",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [800] }
    labels = { severity = "medium" }
      email    = var.deploy_env
    annotations = { summary = "Integration latency > 800ms on API ${var.api_gateway_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 5. Request Count
  rule {
    name = "API Gateway Count Spike - ${var.api_gateway_name}-${var.stage_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApiGateway",
        metricName = "Count",
        dimensions = {
          ApiName = var.api_gateway_name,
          Stage = var.stage_name
        },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [10000] }
    labels = { severity = "medium" }
      email    = var.deploy_env
    annotations = { summary = "Spike in request count on API ${var.api_gateway_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }
}
##############################
# ALB ALERTS
##############################
resource "grafana_rule_group" "alb_alerts" {
  count      = var.alb_name != null ? 1 : 0
  name       = "${var.alb_name} ALB Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  # 1. ELB 5XX
  rule {
    name = "ALB ELB 5XX Errors - ${var.alb_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApplicationELB",
        metricName = "HTTPCode_ELB_5XX_Count",
        dimensions = { LoadBalancer = var.alb_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [10] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "ALB ${var.alb_name} has ELB 5XX errors" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 2. Target 5XX
  rule {
    name = "ALB Target 5XX Errors - ${var.alb_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApplicationELB",
        metricName = "HTTPCode_Target_5XX_Count",
        dimensions = { LoadBalancer = var.alb_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [10] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "ALB ${var.alb_name} has target 5XX errors" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 3. Target Response Time
  rule {
    name = "ALB Target Response Time - ${var.alb_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/ApplicationELB",
        metricName = "TargetResponseTime",
        dimensions = { LoadBalancer = var.alb_name },
        statistic = "Average",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [1] }
    labels = { severity = "high" }
      email    = var.deploy_env
    annotations = { summary = "Target response time > 1s on ALB ${var.alb_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }
}
##############################
# DYNAMODB ALERTS
##############################
resource "grafana_rule_group" "dynamodb_alerts" {
  count      = var.dynamodb_table_name != null ? 1 : 0
  name       = "${var.dynamodb_table_name} DynamoDB Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  # 1. SystemErrors
  rule {
    name      = "DynamoDB SystemErrors - ${var.dynamodb_table_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/DynamoDB",
        metricName = "SystemErrors",
        dimensions = { TableName = var.dynamodb_table_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [1] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "System errors on ${var.dynamodb_table_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 2. ThrottledRequests
  rule {
    name      = "DynamoDB ThrottledRequests - ${var.dynamodb_table_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/DynamoDB",
        metricName = "ThrottledRequests",
        dimensions = { TableName = var.dynamodb_table_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [1] }
    labels = { severity = "critical" }
      email    = var.deploy_env
    annotations = { summary = "Throttling detected on ${var.dynamodb_table_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }

  # 3. SuccessfulRequestLatency
  rule {
    name      = "DynamoDB Latency - ${var.dynamodb_table_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/DynamoDB",
        metricName = "SuccessfulRequestLatency",
        dimensions = { TableName = var.dynamodb_table_name },
        statistic = "Average",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [300] }
    labels = { severity = "high" }
      email    = var.deploy_env
    annotations = { summary = "High latency on ${var.dynamodb_table_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  

  # 4. UserErrors
  rule {
    name      = "DynamoDB UserErrors - ${var.dynamodb_table_name}"
    condition = "B"
    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region = var.aws_region,
        namespace = "AWS/DynamoDB",
        metricName = "UserErrors",
        dimensions = { TableName = var.dynamodb_table_name },
        statistic = "Sum",
        period = 300
      })
    }
    data { ref_id = "B" type = "threshold" params = [5] }
    labels = { severity = "medium" }
      email    = var.deploy_env
    annotations = { summary = "UserErrors detected on ${var.dynamodb_table_name}" }
    no_data_state = "OK"
    exec_err_state = "Alerting"
  }
}