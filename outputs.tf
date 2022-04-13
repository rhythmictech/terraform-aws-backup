output "backup_plan_ids" {
  description = "Backup Plan IDs"
  value       = local.backup_plan_ids
}

output "backup_selection_tags" {
  description = "Tags for backup selection"
  value       = var.backup_selection_tags
}

output "replicate_selection_tags" {
  description = "Tags for backup and replication selection"
  value       = var.replicate_selection_tags
}
