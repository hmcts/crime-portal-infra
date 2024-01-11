variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}

variable "log_analytics_workspaces" {
  type = optional(object({
    daily_quota_gb    = optional(number, 10)
    retention_in_days = optional(number, 30)
  }))
  description = "Configuration values for log analytics workspace. If not set, no workspace will be created."
  default     = null
}
