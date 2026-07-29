variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}
variable "install_azure_monitor" {
  default = false
}

# DTSPO-32146: RSV baseline policy inputs (prod only, see 26-backup-policy.tf).
# Defaults reflect the current live crime-portal-daily-bp-prod policy, so stg
# (which never reads these) and any un-overridden prod value stay unchanged
# until explicitly uplifted in environments/prod/prod.tfvars.
variable "vault_immutability" {
  type        = string
  description = "Immutability setting for the RSV. DTSPO-32146 scope is the policy uplift only; immutability lock is a separate follow-up PR."
  default     = "Disabled"
}

variable "backup_policy_frequency" {
  type    = string
  default = "Daily"
}

variable "backup_policy_time" {
  type    = string
  default = "01:00"
}

variable "backup_hour_interval" {
  type     = number
  default  = null
  nullable = true
}

variable "backup_hour_duration" {
  type     = number
  default  = null
  nullable = true
}

variable "instant_restore_retention_days" {
  type    = number
  default = 1
}

variable "backup_retention_daily_count" {
  type    = number
  default = 28
}

variable "backup_retention_weekly_enabled" {
  type    = bool
  default = false
}

variable "backup_retention_weekly_count" {
  type    = number
  default = 8
}

variable "backup_retention_weekly_weekdays" {
  type    = list(string)
  default = ["Sunday"]
}

variable "backup_retention_monthly_count" {
  type    = number
  default = 12
}

variable "backup_retention_monthly_weekdays" {
  type    = list(string)
  default = ["Sunday"]
}

variable "backup_retention_monthly_weeks" {
  type    = list(string)
  default = ["First"]
}

variable "backup_retention_yearly_count" {
  type    = number
  default = 1
}

variable "backup_retention_yearly_weekdays" {
  type    = list(string)
  default = ["Sunday"]
}

variable "backup_retention_yearly_weeks" {
  type    = list(string)
  default = ["First"]
}

variable "backup_retention_yearly_months" {
  type    = list(string)
  default = ["January"]
}
