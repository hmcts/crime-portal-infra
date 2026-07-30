# DTSPO-32146: crime-portal RSV baseline policy uplift.
#
# Per Daniel Wilson's feedback (30/07), both prod and stg vaults/policies are
# declared here as first-class resource blocks - Terraform is the source of
# truth for both, rather than stg relying on an external data lookup.
#
# The baseline uplift itself remains prod only (Daniel Wilson, 29/07). stg pins
# every input to its current live configuration in environments/stg/stg.tfvars,
# so stg plans as a no-op once imported.
#
# crime-portal-rsv-<env> and crime-portal-daily-bp-<env> already exist in both
# environments (created out-of-band). They must be imported per environment
# before the first apply in that environment:
#
#   terraform import 'azurerm_recovery_services_vault.this[0]' \
#     /subscriptions/<sub>/resourceGroups/crime-portal-rg-<env>/providers/Microsoft.RecoveryServices/vaults/crime-portal-rsv-<env>
#   terraform import 'azurerm_backup_policy_vm.this[0]' \
#     /subscriptions/<sub>/resourceGroups/crime-portal-rg-<env>/providers/Microsoft.RecoveryServices/vaults/crime-portal-rsv-<env>/backupPolicies/crime-portal-daily-bp-<env>
#
# The hardcoded values below were checked against both live vaults/policies and
# already match in each environment, so they do not force any change:
#   sku Standard, GeoRedundant storage, cross region restore enabled,
#   policy_type V2 (both policies are already Enhanced, so no replacement).
#
# The baseline document's sample also sets consistency_type = OnlyCrashConsistent,
# but that argument does not exist on azurerm_backup_policy_vm in the azurerm 4.x
# provider (4.22.0 is pinned here), so it is omitted.
#
# Immutability is left at "Disabled" in both environments, matching live.
# Locking the vault is tracked as a separate follow-up per the ticket.

resource "azurerm_recovery_services_vault" "this" {
  count                 = contains(["prod", "stg"], var.env) ? 1 : 0
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
  count               = contains(["prod", "stg"], var.env) ? 1 : 0
  name                = "crime-portal-daily-bp-${var.env}"
  resource_group_name = local.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this[0].name

  policy_type                    = "V2"
  timezone                       = "UTC"
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
  recovery_vault_name = azurerm_recovery_services_vault.this[0].name
  backup_policy_id    = azurerm_backup_policy_vm.this[0].id
}
