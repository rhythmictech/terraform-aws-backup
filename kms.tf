data "aws_iam_policy_document" "this" {

  statement {
    actions   = ["*"]
    effect    = "Allow"
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow access through AWS Backup for all principals in the account that are authorized to use AWS Backup"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      values   = ["backup.amazonaws.com"]
      variable = "kms:ViaService"
    }

    condition {
      test     = "StringEquals"
      values   = [local.account_id]
      variable = "kms:CallerAccount"
    }
  }
}

resource "aws_kms_key" "this" {
  deletion_window_in_days = 7
  description             = "${var.name} AWS Backup default encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.this.json

  tags = merge(var.tags,
    { "Name" = "${var.name}-awsbackup-default" }
  )
}

resource "aws_kms_alias" "this" {
  name          = "alias/awsbackup"
  target_key_id = aws_kms_key.this.id
}

resource "aws_kms_key" "replica" {
  deletion_window_in_days = 7
  description             = "${var.name} AWS Backup replica encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.this.json

  tags = merge(var.tags,
    { "Name" = "${var.name}-awsbackup-replica" }
  )

  provider = aws.dr
}

resource "aws_kms_alias" "replica" {
  name          = "alias/awsbackup-replica"
  target_key_id = aws_kms_key.replica.id

  provider = aws.dr
}
