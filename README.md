# Terraform GCP uptime monitoring module

![tflint status](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/actions/workflows/tflint.yml/badge.svg?branch=main)

This is a simple module that creates two resources, a `google_monitoring_uptime_check_config` and its alert `google_monitoring_alert_policy`.

You MUST configure the required "google" provider inside your root module.

This module is provided without any kind of warranty and is GPL3 licensed.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.7 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.7 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accepted_response_status_classes"></a> [accepted\_response\_status\_classes](#input\_accepted\_response\_status\_classes) | Check will only pass if the HTTP response status code is in this set of status classes (combined with the set of status values). Possible values: STATUS\_CLASS\_1XX, STATUS\_CLASS\_2XX, STATUS\_CLASS\_3XX, STATUS\_CLASS\_4XX, STATUS\_CLASS\_5XX, STATUS\_CLASS\_ANY | `set(string)` | `[]` | no |
| <a name="input_accepted_response_status_values"></a> [accepted\_response\_status\_values](#input\_accepted\_response\_status\_values) | Check will only pass if the HTTP response status code is in this set of status values (combined with the set of status classes). | `set(number)` | `[]` | no |
| <a name="input_alert_display_name"></a> [alert\_display\_name](#input\_alert\_display\_name) | A human-friendly name for the alert policy. Used for monitoring display\_name. | `string` | `""` | no |
| <a name="input_alert_notification_channels"></a> [alert\_notification\_channels](#input\_alert\_notification\_channels) | Identifies the notification channels to which notifications should be sent when incidents are opened or closed. The syntax of the entries in this field is projects/[PROJECT\_ID]/notificationChannels/[CHANNEL\_ID] | `list(string)` | n/a | yes |
| <a name="input_alert_threshold_duration"></a> [alert\_threshold\_duration](#input\_alert\_threshold\_duration) | The amount of time that a time series must violate the threshold to be considered failing. Currently, only values that are a multiple of a minute--e.g., 0, 60, 120, or 300 seconds--are supported. | `string` | `"60s"` | no |
| <a name="input_alert_threshold_value"></a> [alert\_threshold\_value](#input\_alert\_threshold\_value) | A value against which to compare the time series. | `number` | `1` | no |
| <a name="input_auth_k8s_configmap"></a> [auth\_k8s\_configmap](#input\_auth\_k8s\_configmap) | If your application is behind a basic auth, here you can specify the name of the Kubernetes configmap that contains the credentials. You have to specify the keys for the username and password. | <pre>object({<br>    name         = string<br>    namespace    = string<br>    username_key = string<br>    password_key = string<br>  })</pre> | `null` | no |
| <a name="input_auth_k8s_secret_basic_auth"></a> [auth\_k8s\_secret\_basic\_auth](#input\_auth\_k8s\_secret\_basic\_auth) | If your application is behind a basic auth, here you can specify the name of the Kubernetes secret that contains the basic auth credentials. If you do not specify the `username_key` and `password_key`, the secret must contains the `username` and `password` keys as defined in the `kubernetes.io/basic-auth` type (https://kubernetes.io/docs/concepts/configuration/secret/#basic-authentication-secret). | <pre>object({<br>    name         = string<br>    namespace    = string<br>    username_key = optional(string, "username")<br>    password_key = optional(string, "password")<br>  })</pre> | `null` | no |
| <a name="input_auth_password"></a> [auth\_password](#input\_auth\_password) | If your application is behind a basic auth, here you can specify your password. We recommend to use an env var for you password and do not store it as data plain text in your repo. | `string` | `""` | no |
| <a name="input_auth_username"></a> [auth\_username](#input\_auth\_username) | If your application is behind a basic auth, here you can specify your username. We recommend to use an env var for you password and do not store it as data plain text in your repo. | `string` | `""` | no |
| <a name="input_gcp_project"></a> [gcp\_project](#input\_gcp\_project) | The Google Cloud project ID. | `string` | n/a | yes |
| <a name="input_ssl_alert_threshold_days"></a> [ssl\_alert\_threshold\_days](#input\_ssl\_alert\_threshold\_days) | If you configure this list with some numeric values, the module creates alerts for SSL certificate expiration. The values of the list will be used as threshold value in days for the alert. | `list(number)` | `[]` | no |
| <a name="input_ssl_alert_user_labels"></a> [ssl\_alert\_user\_labels](#input\_ssl\_alert\_user\_labels) | This field is intended to be used for labelling the SSL alerts. Labels and values can contain only lowercase letters, numerals, underscores, and dashes. Keys must begin with a letter. | `map(string)` | `{}` | no |
| <a name="input_uptime_alert_user_labels"></a> [uptime\_alert\_user\_labels](#input\_uptime\_alert\_user\_labels) | This field is intended to be used for labelling the SSL alerts. Labels and values can contain only lowercase letters, numerals, underscores, and dashes. Keys must begin with a letter. | `map(string)` | `{}` | no |
| <a name="input_uptime_check_period"></a> [uptime\_check\_period](#input\_uptime\_check\_period) | How often, in seconds, the uptime check is performed. Currently, the only supported values are 60s (1 minute), 300s (5 minutes), 600s (10 minutes), and 900s (15 minutes). Defaults to 300s. | `string` | `"60s"` | no |
| <a name="input_uptime_check_regions"></a> [uptime\_check\_regions](#input\_uptime\_check\_regions) | The list of regions from which the check will be run. Some regions contain one location, and others contain more than one. If this field is specified, enough regions to include a minimum of 3 locations must be provided, or an error message is returned. Not specifying this field will result in uptime checks running from all regions. | `list(string)` | <pre>[<br>  "USA_VIRGINIA",<br>  "EUROPE",<br>  "ASIA_PACIFIC"<br>]</pre> | no |
| <a name="input_uptime_check_timeout"></a> [uptime\_check\_timeout](#input\_uptime\_check\_timeout) | The maximum amount of time to wait for the request to complete (must be between 1 and 60 seconds). | `string` | `"10s"` | no |
| <a name="input_uptime_monitoring_display_name"></a> [uptime\_monitoring\_display\_name](#input\_uptime\_monitoring\_display\_name) | A human-friendly name for the uptime check configuration. Used for monitoring display\_name. | `string` | `""` | no |
| <a name="input_uptime_monitoring_headers"></a> [uptime\_monitoring\_headers](#input\_uptime\_monitoring\_headers) | A set of key/value header pairs to send in the HTTP request to the URL. | `map(string)` | `{}` | no |
| <a name="input_uptime_monitoring_host"></a> [uptime\_monitoring\_host](#input\_uptime\_monitoring\_host) | A hostname to monitor (without protocol, example: 'www.my-site.com'). | `string` | n/a | yes |
| <a name="input_uptime_monitoring_path"></a> [uptime\_monitoring\_path](#input\_uptime\_monitoring\_path) | The path to the page to run the check against. | `string` | `"/"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_policy_name"></a> [alert\_policy\_name](#output\_alert\_policy\_name) | n/a |
| <a name="output_http_uptime_monitoring_name"></a> [http\_uptime\_monitoring\_name](#output\_http\_uptime\_monitoring\_name) | n/a |
| <a name="output_ssl_alert_policy_names"></a> [ssl\_alert\_policy\_names](#output\_ssl\_alert\_policy\_names) | n/a |
## Resources

| Name | Type |
|------|------|
| [google_monitoring_alert_policy.failure_alert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.ssl_expiring_days](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_uptime_check_config.https_uptime](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_uptime_check_config) | resource |
| [kubernetes_config_map_v1.basic_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/config_map_v1) | data source |
| [kubernetes_secret_v1.basic_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) | data source |
## Modules

No modules.
<!-- END_TF_DOCS -->
