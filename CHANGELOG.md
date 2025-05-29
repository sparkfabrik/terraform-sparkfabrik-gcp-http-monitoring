# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-07-09

[Compare with previous version](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/compare/0.10.0...1.0.0)

### Added

- Add support for custom headers in the uptime check.

## [0.10.0] - 2024-05-31

[Compare with previous version](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/compare/0.9.0...0.10.0)

### Added

- Add support to fetch basic auth credentials from a Kubernetes secret or a configmap.

## [0.9.0] - 2024-02-24

[Compare with previous version](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/compare/0.8.0...0.9.0)

- Changed default regions to ["EUROPE","ASIA_PACIFIC","USA_VIRGINIA"].
- Set threshold value to 1 as default.

## [0.8.0] - 2023-08-24

[Compare with previous version](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/compare/0.7.1...0.8.0)

- Add response status code and response status classes

## [0.7.1] - 2023-07-18

[Compare with previous version](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/compare/0.7.0...0.7.1)

- Add path to the uptime check display name only if it is different from `/`.

## [0.7.0] - 2023-07-04

[Compare with previous version](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/compare/0.6.0...0.7.0)

- Add `uptime_monitoring_path` to display name of uptime check.

## [0.6.0] - 2022-10-10

- Add SSL expiration alert policy feature.

## [0.5.2] - 2022-10-05

### Changed

- Se default locations in ASIA_PACIFIC, EUROPE, and SOUTH_AMERICA since each include 1 region. USA include 3 regions, and we want to stay with the [minimum of 3 regions distributed globally](https://cloud.google.com/stackdriver/pricing#pricing_examples_uptime).

## [0.5.1] - 2022-10-04

### Changed

- Fix the default check regions.

## [0.5.0] - 2022-10-04

### Changed

Given the recent change in [Google's monitoring price policy](https://cloud.google.com/stackdriver/pricing#pricing_examples_uptime),
we have introduced the following changes in the default values:

- Set the number of region from Global to `eur-belgium`, `usa-virginia`, `apac-singapore` for `uptime_check_regions`
- `alert_threshold_value` is now set to 2 as default.

### Fixed

- [Support uptime check config updates](https://github.com/sparkfabrik/terraform-sparkfabrik-gcp-http-monitoring/issues/5)

## [0.4.0] - 2022-04-28

### Changed

This release is a **breaking change** since 0.3, regarding input variables:

- We have changed the variables used for the basic auth, now you can find `auth_username` and `auth_password` which represent you credentials. Both variables must be filled if you want to enable the basic auth feature. The variable `auth_credentials` was **removed**.

## [0.3.0] - 2022-04-20

### Changed

This release is a **breaking change** since 0.2, regarding input variables and how the module works:

- we have removed multi-host support
- the host to monitor is a single value variable (from `list` to `string`), and it has been renamed accordingly: `uptime_monitoring_hosts` => `uptime_monitoring_host`
- the google provider needs to be configured at root module level (the gcp_region variable is no longer supported)
