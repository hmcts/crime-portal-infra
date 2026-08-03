variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}
variable "install_azure_monitor" {
  default = false
}

variable "backup_schedule" {
  type = object({
    frequency     = string
    time          = string
    hour_interval = optional(number)
    hour_duration = optional(number)
  })
  description = "Backup schedule for the VM backup policy."
  default = {
    frequency     = "Hourly"
    time          = "01:00"
    hour_interval = 4
    hour_duration = 24
  }
}

variable "instant_restore_retention_days" {
  type        = number
  description = "Instant restore retention in days."
  default     = 7
}

variable "backup_retention_daily_count" {
  type        = number
  description = "Number of daily recovery points to retain."
  default     = 56
}

variable "backup_retention_weekly" {
  type = object({
    count    = number
    weekdays = list(string)
  })
  description = "Weekly retention tier."
  default = {
    count    = 8
    weekdays = ["Sunday"]
  }
}

variable "backup_retention_monthly" {
  type = object({
    count    = number
    weekdays = list(string)
    weeks    = list(string)
  })
  description = "Monthly retention tier."
  default = {
    count    = 2
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

variable "backup_retention_yearly" {
  type = object({
    count    = number
    weekdays = list(string)
    weeks    = list(string)
    months   = list(string)
  })
  description = "Yearly retention tier."
  default = {
    count    = 1
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}
