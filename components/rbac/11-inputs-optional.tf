variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}

variable "ldap_users" {
  type = map(object({
    is_group               = optional(bool, false)
    group_security_enabled = optional(bool, false)
    is_user                = optional(bool, false)
    is_service_principal   = optional(bool, false)
    role_type              = string
  }))
  description = "Map of objects describing the users, groups and service principals who should be able to access the LDAP VMs."
  default     = {}
  validation {
    condition = alltrue([
      for user in var.ldap_users : anytrue([user.is_group != null], [user.is_user != null], [user.is_service_principal != null])
      && contains(["admin", "user"], lower(user.role_type))
    ])
    error_message = "One of is_group, is_user or is_service_principal must be set to true for each user, group or service principal. The valid values for role_type are admin and user."
  }
}
