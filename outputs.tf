output "http_uptime_monitoring_name" {
  value = google_monitoring_uptime_check_config.https_uptime.name
}

output "alert_policy_name" {
  value = google_monitoring_alert_policy.failure_alert.name
}
