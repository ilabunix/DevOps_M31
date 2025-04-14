
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
}
##############################
# ACM CERTIFICATE ALERTS
##############################
resource "grafana_rule_group" "acm_alerts" {
  count      = var.certificate_name != null ? 1 : 0
  name       = "${var.certificate_name} ACM Certificate Alerts"
  folder_uid = var.folder_uid
  interval   = "1h"

  dynamic "rule" {
    for_each = toset(var.acm_expiry_thresholds)
    content {
      name = "Cert Expiry < ${rule.value}d - ${var.certificate_name}"
      condition = "B"
      data {
        ref_id = "A"
        relative_time_range { from = 3600 to = 0 }
        datasource_uid = var.datasource_uid
        model = jsonencode({
          region     = var.aws_region,
          namespace  = "Custom/ACM",
          metricName = "DaysToExpiry",
          dimensions = {
            CertificateName = var.certificate_name
          },
          statistic = "Minimum",
          period    = 3600
        })
      }
      data { ref_id = "B" type = "threshold" params = [rule.value] }
      annotations = {
        summary = "Certificate ${var.certificate_name} expires in <${rule.value} days"
      }
      labels = {
      email    = var.deploy_env
        severity = rule.value <= 1 ? "critical" :
                   rule.value <= 7 ? "high" :
                   rule.value <= 15 ? "medium" : "info"
      }
      no_data_state  = "OK"
      exec_err_state = "Alerting"
    }
  }
}
##############################
# EXPANDED API GATEWAY ALERTS
##############################
# Metrics covered: 5XXError, 4XXError, Latency, IntegrationLatency, Count spike, CacheHitRate

resource "grafana_rule_group" "apigw_alerts" {
  count      = var.api_gateway_name != null ? 1 : 0
  name       = "${var.api_gateway_name}-${var.stage_name} API Gateway Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  # Example rule: CacheHitRate < 60%
  rule {
    name = "API Gateway Cache Hit Rate Low - ${var.api_gateway_name}-${var.stage_name}"
    condition = "B"

    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region     = var.aws_region,
        namespace  = "AWS/ApiGateway",
        metricName = "CacheHitCount",
        dimensions = {
          ApiName = var.api_gateway_name,
          Stage = var.stage_name
        },
        statistic = "Sum",
        period    = 300
      })
    }

    data {
      ref_id = "B"
      type   = "threshold"
      params = [var.cache_hit_threshold]
    }

    labels = {
      severity = "medium"
      email    = var.deploy_env
    }

    annotations = {
      summary = "Cache hit rate is low for API ${var.api_gateway_name}"
    }

    no_data_state  = "OK"
    exec_err_state = "Alerting"
  }
}

##############################
# EXPANDED ALB ALERTS
##############################
# Metrics: TLSNegotiationErrorCount, ELBAuthError, ELBAuthLatency, ConnectionCount

resource "grafana_rule_group" "alb_alerts" {
  count      = var.alb_name != null ? 1 : 0
  name       = "${var.alb_name} ALB Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  # Example: TLSNegotiationErrorCount > 10
  rule {
    name = "TLS Negotiation Errors - ${var.alb_name}"
    condition = "B"

    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region     = var.aws_region,
        namespace  = "AWS/ApplicationELB",
        metricName = "TLSNegotiationErrorCount",
        dimensions = {
          LoadBalancer = var.alb_name
        },
        statistic = "Sum",
        period    = 300
      })
    }

    data {
      ref_id = "B"
      type   = "threshold"
      params = [var.alb_tls_error_threshold]
    }

    labels = {
      severity = "critical"
      email    = var.deploy_env
    }

    annotations = {
      summary = "High TLS negotiation errors on ALB ${var.alb_name}"
    }

    no_data_state  = "OK"
    exec_err_state = "Alerting"
  }
}

##############################
# EXPANDED DYNAMODB ALERTS
##############################
# Metrics: ReplicationLatency, PendingReplicationCount, CapacityUtilization

resource "grafana_rule_group" "dynamodb_alerts" {
  count      = var.dynamodb_table_name != null ? 1 : 0
  name       = "${var.dynamodb_table_name} DynamoDB Alerts"
  folder_uid = var.folder_uid
  interval   = "1m"

  # Example: ReplicationLatency > 30s
  rule {
    name = "DynamoDB Replication Latency - ${var.dynamodb_table_name}"
    condition = "B"

    data {
      ref_id = "A"
      relative_time_range { from = 300 to = 0 }
      datasource_uid = var.datasource_uid
      model = jsonencode({
        region     = var.aws_region,
        namespace  = "AWS/DynamoDB",
        metricName = "ReplicationLatency",
        dimensions = {
          TableName = var.dynamodb_table_name
        },
        statistic = "Maximum",
        period    = 300
      })
    }

    data {
      ref_id = "B"
      type   = "threshold"
      params = [var.dynamodb_replication_latency_threshold]
    }

    labels = {
      severity = "high"
      email    = var.deploy_env
    }

    annotations = {
      summary = "High replication latency detected for ${var.dynamodb_table_name}"
    }

    no_data_state  = "OK"
    exec_err_state = "Alerting"
  }
}
