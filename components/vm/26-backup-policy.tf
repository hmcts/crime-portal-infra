# DTSPO-32146: crime-portal RSV baseline policy uplift - prod only.
#
# crime-portal-rsv-prod and crime-portal-daily-bp-prod already exist (created
# out-of-band, previously only referenced via data source). Bringing them
# under Terraform management here requires an import before the first apply:
#
#   terraform import 'azurerm_recovery_services_vault.this[0]' \
#     /subscriptions/<sub>/resourceGroups/crime-portal-rg-prod/providers/Microsoft.RecoveryServices/vaults/crime-portal-rsv-prod
#   terraform import 'azurerm_backup_policy_vm.this[0]' \
#     /subscriptions/<sub>/resourceGroups/crime-portal-rg-prod/providers/Microsoft.RecoveryServices/vaults/crime-portal-rsv-prod/backupPolicies/crime-portal-daily-bp-prod
#
# stg is intentionally out of scope (Daniel Wilson, 29/07) and continues to use
# the existing out-of-band policy via data.azurerm_backup_policy_vm.policy in
# 12-interpolated-defaults.tf.
#
# Immutability is left at "Disabled" (var.vault_immutability default) in this
# PR - locking the vault is tracked as a separate follow-up per the ticket.

resource "azurerm_recovery_services_vault" "this" {
  count                 = var.env == "prod" ? 1 : 0
  name                  = "crime-portal-rsv-${var.env}"
  resource_group_name   = local.resource_group_name
  location              = var.location
  sku                   = "Standard"
  storage_mode_type     = "GeoRedundant"
  cross_region_restore_enabled = true
  immutability          = var.vault_immutability
  tags                  = module.ctags.common_tags
}

resource "azurerm_backup_policy_vm" "this" {
  count               = var.env == "prod" ? 1 : 0
  name                = "crime-portal-daily-bp-${var.env}"
  resource_group_name = local.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this[0].name

  policy_type                    = "V2"
  timezone                       = "UTC"
  consistency_type               = "OnlyCrashConsistent"
  instant_restore_retention_days = var.instant_restore_retention_days

  backup {
    frequency     = var.backup_policy_frequency
    time          = var.backup_policy_time
    hour_interval = var.backup_hour_interval
    hour_duration = var.backup_hour_duration
  }

  retention_daily {
    count = var.backup_retention_daily_count
  }

  dynamic "retention_weekly" {
    for_each = var.backup_retention_weekly_enabled ? [1] : []
    content {
      count    = var.backup_retention_weekly_count
      weekdays = var.backup_retention_weekly_weekdays
    }
  }

  retention_monthly {
    count    = var.backup_retention_monthly_count
    weekdays = var.backup_retention_monthly_weekdays
    weeks    = var.backup_retention_monthly_weeks
  }

  retention_yearly {
    count    = var.backup_retention_yearly_count
    weekdays = var.backup_retention_yearly_weekdays
    weeks    = var.backup_retention_yearly_weeks
    months   = var.backup_retention_yearly_months
  }
}

locals {
  recovery_vault_name = var.env == "prod" ? azurerm_recovery_services_vault.this[0].name : "crime-portal-rsv-${var.env}"
  backup_policy_id    = var.env == "prod" ? azurerm_backup_policy_vm.this[0].id : data.azurerm_backup_policy_vm.policy[0].id
}
