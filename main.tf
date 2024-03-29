# ------
# LOCALS
# ------
locals {
  suffix                         = var.uptime_monitoring_path != "/" ? var.uptime_monitoring_path : ""
  uptime_monitoring_display_name = var.uptime_monitoring_display_name != "" ? "${var.uptime_monitoring_display_name} - ${var.uptime_monitoring_host}${local.suffix}" : "${var.uptime_monitoring_host}${local.suffix}"
}

# -------------
# Alerts policy
# -------------
resource "google_monitoring_alert_policy" "failure_alert" {
  display_name = "Failure of uptime check for: ${local.uptime_monitoring_display_name}"
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
    display_name = "Failure of uptime check for: ${local.uptime_monitoring_display_name}"
  }

  user_labels = var.uptime_alert_user_labels

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
      for_each = (length(var.auth_username) > 0 && length(var.auth_password) > 0) ? [1] : []
      content {
        username = var.auth_username
        password = var.auth_password
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
