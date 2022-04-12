########################################
# General Vars
########################################

variable "backup_selection_tags" {
  description = "Tags for backup selection"
  type        = list(map(string))
  default = [{
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "daily"
  }]
}

variable "replicate_selection_tags" {
  description = "Tags for backup and replication selection"
  type        = list(map(string))
  default = [{
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "daily_and_replicate"
  }]
}

variable "completion_window" {
  default     = 420
  description = "Number of minutes to allow jobs to run"
  type        = number
}

variable "dr_region" {
  default     = "us-east-2"
  description = "Region to place replica vault in"
  type        = string
}

variable "name" {
  description = "Moniker to apply to all resources in the module"
  type        = string
}

variable "primary_retain_days" {
  default     = 90
  description = "Number of days to retain backups in primary site"
  type        = number
}

variable "replica_retain_days" {
  default     = 90
  description = "Number of days to retain backups in primary site"
  type        = number
}

variable "schedule" {
  default     = "cron(0 5 * * ? *)"
  description = "Backup schedule for all jobs"
  type        = string
}

variable "tags" {
  default     = {}
  description = "User-Defined tags"
  type        = map(string)
}
