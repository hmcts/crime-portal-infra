variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}
variable "install_azure_monitor" {
  default = false
}

variable "activityName" {
  type        = string
  description = "The name of the activity"
}

variable "application" {
  type        = string
  description = "The type of the application"
}