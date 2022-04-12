provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  backup_plan_ids = [
    aws_backup_plan.this.id,
    aws_backup_plan.and_replicate.id
  ]
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

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
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

resource "aws_backup_plan" "and_replicate" {
  name = "${var.name}_replicated"
  tags = var.tags

  rule {
    rule_name           = "${var.name}_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "${var.name}_replicated" })
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

resource "aws_backup_plan" "this" {
  name = "${var.name}_no_replication"
  tags = var.tags

  rule {
    rule_name           = "${var.name}_backup"
    completion_window   = var.completion_window
    recovery_point_tags = merge(var.tags, { BackupPlan = "${var.name}_no_replication" })
    schedule            = var.schedule
    target_vault_name   = aws_backup_vault.primary.name

    lifecycle {
      delete_after = var.primary_retain_days
    }
  }
}

resource "aws_backup_selection" "this" {
  name         = "${var.name}_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.this.id

  dynamic "selection_tag" {
    for_each = var.backup_selection_tags
    content {
      type  = lookup(selection_tag.value, "type", null)
      key   = lookup(selection_tag.value, "key", null)
      value = lookup(selection_tag.value, "value", null)
    }
  }
}

resource "aws_backup_selection" "and_replicate" {
  name         = "${var.name}_and_replicate_backup_selection"
  iam_role_arn = aws_iam_role.this.arn
  plan_id      = aws_backup_plan.and_replicate.id

  dynamic "selection_tag" {
    for_each = var.replicate_selection_tags
    content {
      type  = lookup(selection_tag.value, "type", null)
      key   = lookup(selection_tag.value, "key", null)
      value = lookup(selection_tag.value, "value", null)
    }
  }
}
