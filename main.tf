# ------
# LOCALS
# ------
locals {
  suffix                          = var.uptime_monitoring_path != "/" ? var.uptime_monitoring_path : ""
  uptime_monitoring_display_name  = var.uptime_monitoring_display_name != "" ? "${var.uptime_monitoring_display_name} - ${var.uptime_monitoring_host}${local.suffix}" : "${var.uptime_monitoring_host}${local.suffix}"
  alert_display_name              = var.alert_display_name != "" ? "${var.alert_display_name}" :  "Failure of uptime check for: ${local.uptime_monitoring_display_name}"
}

# Fetch information from Kubernetes secret if they are needed
data "kubernetes_secret_v1" "basic_auth" {
  count = var.auth_k8s_secret_basic_auth != null ? 1 : 0

  metadata {
    name      = var.auth_k8s_secret_basic_auth.name
    namespace = var.auth_k8s_secret_basic_auth.namespace
  }
}

# Fetch information from Kubernetes configmap if they are needed
data "kubernetes_config_map_v1" "basic_auth" {
  count = var.auth_k8s_configmap != null ? 1 : 0

  metadata {
    name      = var.auth_k8s_configmap.name
    namespace = var.auth_k8s_configmap.namespace
  }
}

locals {
  secret_username    = length(data.kubernetes_secret_v1.basic_auth) == 1 ? lookup(data.kubernetes_secret_v1.basic_auth[0].data, var.auth_k8s_secret_basic_auth.username_key, "") : ""
  secret_password    = length(data.kubernetes_secret_v1.basic_auth) == 1 ? lookup(data.kubernetes_secret_v1.basic_auth[0].data, var.auth_k8s_secret_basic_auth.password_key, "") : ""
  configmap_username = length(data.kubernetes_config_map_v1.basic_auth) == 1 ? lookup(data.kubernetes_config_map_v1.basic_auth[0].data, var.auth_k8s_configmap.username_key, "") : ""
  configmap_password = length(data.kubernetes_config_map_v1.basic_auth) == 1 ? lookup(data.kubernetes_config_map_v1.basic_auth[0].data, var.auth_k8s_configmap.password_key, "") : ""

  final_username = try(coalesce(var.auth_username, local.secret_username, local.configmap_username), "")
  final_password = try(coalesce(var.auth_password, local.secret_password, local.configmap_password), "")
}

resource "google_monitoring_uptime_check_config" "https_uptime" {
  display_name     = local.uptime_monitoring_display_name
  timeout          = var.uptime_check_timeout
  period           = var.uptime_check_period
  selected_regions = var.uptime_check_regions

  http_check {
    path         = var.uptime_monitoring_path
    port         = "443"
    use_ssl      = true
    validate_ssl = true
    headers      = var.uptime_monitoring_headers

    dynamic "auth_info" {
      for_each = (length(local.final_username) > 0 && length(local.final_password) > 0) ? [1] : []
      content {
        username = local.final_username
        password = local.final_password
      }
    }

    dynamic "accepted_response_status_codes" {
      for_each = var.accepted_response_status_values

      content {
        status_value = accepted_response_status_codes.value
      }
    }

    dynamic "accepted_response_status_codes" {
      for_each = var.accepted_response_status_classes

      content {
        status_class = accepted_response_status_codes.value
      }
    }
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project
      host       = var.uptime_monitoring_host
    }
  }

  project = var.gcp_project

  lifecycle {
    create_before_destroy = true
  }
}

# -------------
# Alerts policy
# -------------
resource "google_monitoring_alert_policy" "failure_alert" {
  display_name = local.alert_display_name
  combiner     = "OR"

  conditions {
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.https_uptime.uptime_check_id}\" AND resource.type=\"uptime_url\""
      comparison      = "COMPARISON_LT"
      threshold_value = var.alert_threshold_value
      duration        = var.alert_threshold_duration
      trigger {
        count = 1
      }
      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_TRUE"
        group_by_fields      = []
      }
    }
    display_name = local.alert_display_name
  }

  user_labels = var.uptime_alert_user_labels

  notification_channels = var.alert_notification_channels
  project               = var.gcp_project

  depends_on = [
    google_monitoring_uptime_check_config.https_uptime
  ]
}

# ----------------------------
# SSL expiration alert policy
# ----------------------------
resource "google_monitoring_alert_policy" "ssl_expiring_days" {
  for_each = toset([for days in var.ssl_alert_threshold_days : tostring(days)])

  display_name = "SSL certificate expiring soon (${each.value} days)"
  combiner     = "OR"
  conditions {
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/time_until_ssl_cert_expires\" AND resource.type=\"uptime_url\""
      comparison      = "COMPARISON_LT"
      threshold_value = each.value
      duration        = "600s"
      trigger {
        count = 1
      }
      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = [
          "resource.label.*"
        ]
      }
    }
    display_name = "SSL certificate expiring soon (${each.value} days)"
  }

  user_labels = var.ssl_alert_user_labels

  notification_channels = var.alert_notification_channels
  project               = var.gcp_project

  depends_on = [
    google_monitoring_uptime_check_config.https_uptime
  ]
}
