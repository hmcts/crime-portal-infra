# terraform import 'azurerm_backup_policy_vm.this[0]' /subscriptions/<sub>/resourceGroups/crime-portal-rg-prod/providers/Microsoft.RecoveryServices/vaults/crime-portal-rsv-prod/backupPolicies/crime-portal-daily-bp-prod

resource "azurerm_backup_policy_vm" "this" {
  count               = var.env == "prod" ? 1 : 0
  name                = "crime-portal-daily-bp-${var.env}"
  resource_group_name = local.resource_group_name
  recovery_vault_name = data.azurerm_recovery_services_vault.this.name

  policy_type                    = "V2"
  timezone                       = "UTC"
  instant_restore_retention_days = var.instant_restore_retention_days

  backup {
    frequency     = var.backup_schedule.frequency
    time          = var.backup_schedule.time
    hour_interval = var.backup_schedule.hour_interval
    hour_duration = var.backup_schedule.hour_duration
  }

  retention_daily {
    count = var.backup_retention_daily_count
  }

  dynamic "retention_weekly" {
    for_each = var.backup_retention_weekly != null ? [var.backup_retention_weekly] : []
    content {
      count    = retention_weekly.value.count
      weekdays = retention_weekly.value.weekdays
    }
  }

  retention_monthly {
    count    = var.backup_retention_monthly.count
    weekdays = var.backup_retention_monthly.weekdays
    weeks    = var.backup_retention_monthly.weeks
  }

  retention_yearly {
    count    = var.backup_retention_yearly.count
    weekdays = var.backup_retention_yearly.weekdays
    weeks    = var.backup_retention_yearly.weeks
    months   = var.backup_retention_yearly.months
  }
}
