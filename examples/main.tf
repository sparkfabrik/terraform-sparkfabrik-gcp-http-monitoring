locals {
  gcp_project = "project_id"
  hosts_list = {
    "www.acme-site.it" : {},
    "www2.acme-site.it" : {},
    "test.acme-site.it" : {},
    "test2.acme-site.it" : {},
    "1.2.3.4" : {
      headers = {
        "Host" = "www.acme-site.it"
      }
    }
  }
  notification_channels = [
    google_monitoring_notification_channel.cloud_support_email.name,
    google_monitoring_notification_channel.dev_support_email.name,
  ]
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
  display_name = "Email developers support"
  type         = "email"
  labels = {
    email_address = "dev-support@acme.com"
  }
  enabled = true
  project = local.gcp_project
}

module "gcp-http-monitoring" {
  source   = "sparkfabrik/gcp-http-monitoring/sparkfabrik"
  version  = "~>1.0"
  for_each = local.hosts_list

  uptime_monitoring_host      = each.key
  uptime_monitoring_headers   = try(each.value.headers, {})
  gcp_project                 = local.gcp_project
  alert_threshold_duration    = "300s"
  alert_notification_channels = local.notification_channels
  uptime_monitoring_path      = var.monitoring_path
  auth_username               = var.basic_auth_user
  auth_password               = var.basic_auth_password
}
