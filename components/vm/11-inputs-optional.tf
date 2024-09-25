variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}
variable "install_azure_monitor" {
  default = false
}