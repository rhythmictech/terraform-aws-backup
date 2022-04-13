# terraform-aws-backup
Creates a backup vault, backup plan, and tag-based backup selection. Optionally replicates this all to a DR region. 


[![tflint](https://github.com/rhythmictech/terraform-aws-backup/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-backup/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-backup/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-backup/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-backup/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-backup/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-backup/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-backup/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-backup/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-backup/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example

Create the backup resources with terraform:

```hcl
module "backup" {
  source = "git@github.com:rhythmictech/terraform-aws-backup.git?ref=master"

  name              = "backups"
  tags              = var.tags
}
```

Then tag resources you'd like to back up. By default use the key `BACKUP_POLICY` and a value of one of:
- `daily` to create backups of resources every day at 5 am
- `daily_and_replicate` to also replicate these resources to a DR region

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |
| <a name="provider_aws.dr"></a> [aws.dr](#provider\_aws.dr) | 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.and_replicate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.and_replicate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.restore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_selection_tags"></a> [backup\_selection\_tags](#input\_backup\_selection\_tags) | Tags for backup selection | `list(map(string))` | <pre>[<br>  {<br>    "key": "BACKUP_POLICY",<br>    "type": "STRINGEQUALS",<br>    "value": "daily"<br>  }<br>]</pre> | no |
| <a name="input_completion_window"></a> [completion\_window](#input\_completion\_window) | Number of minutes to allow jobs to run | `number` | `420` | no |
| <a name="input_dr_region"></a> [dr\_region](#input\_dr\_region) | Region to place replica vault in | `string` | `"us-east-2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Moniker to apply to all resources in the module | `string` | n/a | yes |
| <a name="input_primary_retain_days"></a> [primary\_retain\_days](#input\_primary\_retain\_days) | Number of days to retain backups in primary site | `number` | `90` | no |
| <a name="input_replica_retain_days"></a> [replica\_retain\_days](#input\_replica\_retain\_days) | Number of days to retain backups in primary site | `number` | `90` | no |
| <a name="input_replicate_selection_tags"></a> [replicate\_selection\_tags](#input\_replicate\_selection\_tags) | Tags for backup and replication selection | `list(map(string))` | <pre>[<br>  {<br>    "key": "BACKUP_POLICY",<br>    "type": "STRINGEQUALS",<br>    "value": "daily_and_replicate"<br>  }<br>]</pre> | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Backup schedule for all jobs | `string` | `"cron(0 5 * * ? *)"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | User-Defined tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_ids"></a> [backup\_plan\_ids](#output\_backup\_plan\_ids) | Backup Plan IDs |
| <a name="output_backup_selection_tags"></a> [backup\_selection\_tags](#output\_backup\_selection\_tags) | Tags for backup selection |
| <a name="output_replicate_selection_tags"></a> [replicate\_selection\_tags](#output\_replicate\_selection\_tags) | Tags for backup and replication selection |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Getting Started
This workflow has a few prerequisites which are installed through the `./bin/install-x.sh` scripts and are linked below. The install script will also work on your local machine. 

- [pre-commit](https://pre-commit.com)
- [terraform](https://terraform.io)
- [tfenv](https://github.com/tfutils/tfenv)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [tfsec](https://github.com/tfsec/tfsec)
- [tflint](https://github.com/terraform-linters/tflint)

We use `tfenv` to manage `terraform` versions, so the version is defined in the `versions.tf` and `tfenv` installs the latest compliant version.
`pre-commit` is like a package manager for scripts that integrate with git hooks. We use them to run the rest of the tools before apply. 
`terraform-docs` creates the beautiful docs (above),  `tfsec` scans for security no-nos, `tflint` scans for best practices. 
