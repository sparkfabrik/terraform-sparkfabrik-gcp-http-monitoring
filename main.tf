# ------
# LOCALS
# ------
locals {
  uptime_monitoring_display_name = var.uptime_monitoring_display_name != "" ? var.uptime_monitoring_display_name : var.uptime_monitoring_host
}

# -------------
# Alerts policy
# -------------
resource "google_monitoring_alert_policy" "failure_alert" {
  display_name = "${local.uptime_monitoring_display_name} - Uptime failure"
  combiner     = "OR"
  user_labels  = {}
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
    display_name = "Failure of uptime check for: ${local.uptime_monitoring_display_name}"
  }

  notification_channels = var.alert_notification_channels
  project               = var.gcp_project

  depends_on = [
    google_monitoring_uptime_check_config.https_uptime
  ]
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

    dynamic "auth_info" {
      for_each = var.auth_credentials
      content {
        username = auth_info.key
        password = auth_info.value
      }
    }
  }

  monitored_resource {
    type   = "uptime_url"
    labels = {
      project_id = var.gcp_project
      host       = var.uptime_monitoring_host
    }
  }

  project = var.gcp_project
}
