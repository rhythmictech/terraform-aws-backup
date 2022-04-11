provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  backup_plan_ids = {
    "monthly"                       = aws_backup_plan.monthly.id
    "nightly"                       = aws_backup_plan.nightly.id
    "nightly_and_replicate"         = aws_backup_plan.nightly_and_replicate.id
    "nightly_and_replicate_windows" = aws_backup_plan.nightly_and_replicate_windows.id
    "nightly_windows"               = aws_backup_plan.nightly_windows.id
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_vault" "replica" {
  name        = "${var.name}-replicavault"
  kms_key_arn = aws_kms_key.replica.arn
  tags        = var.tags

  provider = aws.dr
}

resource "aws_backup_vault" "primary" {
  name        = "${var.name}-primaryvault"
  kms_key_arn = aws_kms_key.this.arn
  tags        = var.tags
}

# AWS Backup plan
resource "aws_backup_plan" "nightly_and_replicate" {
  name = "nightly_replicated"
  tags = var.tags

  rule {
    rule_name           = "nightly_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "nightly_replicated" })
    schedule            = var.schedule
    target_vault_name   = aws_backup_vault.primary.name

    copy_action {
      destination_vault_arn = aws_backup_vault.replica.arn

      lifecycle {
        delete_after = var.replica_retain_days
      }
    }

    lifecycle {
      delete_after = var.primary_retain_days
    }
  }
}

resource "aws_backup_plan" "nightly_and_replicate_windows" {
  name = "nightly_replicated_win"
  tags = var.tags

  rule {
    rule_name           = "nightly_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "nightly_replicated_win" })
    schedule            = var.schedule
    target_vault_name   = aws_backup_vault.primary.name

    copy_action {
      destination_vault_arn = aws_backup_vault.replica.arn

      lifecycle {
        delete_after = var.replica_retain_days
      }
    }

    lifecycle {
      delete_after = var.primary_retain_days
    }
  }

  advanced_backup_setting {
    resource_type = "EC2"

    backup_options = {
      WindowsVSS = "enabled"
    }
  }
}

resource "aws_backup_plan" "nightly" {
  name = "nightly_no_replication"
  tags = var.tags

  rule {
    rule_name           = "nightly_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "nightly_no_replication" })
    schedule            = var.schedule
    target_vault_name   = aws_backup_vault.primary.name

    lifecycle {
      delete_after = var.primary_retain_days
    }
  }
}

resource "aws_backup_plan" "nightly_windows" {
  name = "nightly_no_replication_windows"
  tags = var.tags

  rule {
    rule_name           = "nightly_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "nightly_no_replication_windows" })
    schedule            = var.schedule
    target_vault_name   = aws_backup_vault.primary.name

    lifecycle {
      delete_after = var.primary_retain_days
    }
  }

  advanced_backup_setting {
    resource_type = "EC2"

    backup_options = {
      WindowsVSS = "enabled"
    }
  }
}

resource "aws_backup_plan" "monthly" {
  name = "monthly_no_replication"
  tags = var.tags

  rule {
    rule_name           = "monthly_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "monthly_no_replication" })
    schedule            = var.schedule
    target_vault_name   = aws_backup_vault.primary.name

    lifecycle {
      delete_after = var.primary_monthly_retain_days
    }
  }
}

resource "aws_backup_selection" "monthly" {
  name         = "monthly_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.monthly.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "monthly"
  }
}

resource "aws_backup_selection" "nightly" {
  name         = "nightly_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.nightly.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "nightly"
  }
}

resource "aws_backup_selection" "nightly_and_replicate" {
  name         = "nightly_and_replicate_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.nightly_and_replicate.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "nightly_and_replicate"
  }
}

resource "aws_backup_selection" "nightly_and_replicate_windows" {
  name         = "nightly_and_replicate_windows_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.nightly_and_replicate_windows.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "nightly_and_replicate_windows"
  }
}

resource "aws_backup_selection" "nightly_windows" {
  name         = "nightly_windows_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.nightly_windows.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BACKUP_POLICY"
    value = "nightly_windows"
  }
}
