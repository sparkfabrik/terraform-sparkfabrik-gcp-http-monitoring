locals {
  gcp_project = "project_id"
  gcp_region = "europe-west1"
  hosts_list = [
    "www.acme-site.it",
    "www2.acme-site.it",
    "test.acme-site.it",
    "test2.acme-site.it"
  ]
  notification_channels = [
    google_monitoring_notification_channel.cloud_support_email.name,
    google_monitoring_notification_channel.dev_support_email.name,
  ]
  uptime_monitoring_path = "/healthz"
}


# Create notification channels.
resource "google_monitoring_notification_channel" "cloud_support_email" {
  display_name = "Email cloud support"
  type         = "email"
  labels = {
    email_address = "cloud-support@acme.com"
  }
  enabled = true
  project = local.gcp_project
}

resource "google_monitoring_notification_channel" "dev_support_email" {
  display_name = "Email cloud support"
  type         = "email"
  labels = {
    email_address = "dev-support@acme.com"
  }
  enabled = true
  project = local.gcp_project
}

module "gcp-http-monitoring" {
  source  = "sparkfabrik/gcp-http-monitoring/sparkfabrik"
  version = "0.1.2"
  gcp_project = local.gcp_project
  gcp_region = local.gcp_region
  uptime_monitoring_hosts = local.hosts_list
  alert_threshold_duration = "300s"
  alert_notification_channels = local.notification_channels
  uptime_monitoring_path = local.uptime_monitoring_path
  auth_credentials = {
    var.basic_auth_user = var.basic_auth_password
  }
}