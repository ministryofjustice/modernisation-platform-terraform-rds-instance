# Modernisation Platform Terraform RDS Instance

[![Standards Icon]][Standards Link] [![Format Code Icon]][Format Code Link] [![Scorecards Icon]][Scorecards Link] [![SCA Icon]][SCA Link] [![Terraform SCA Icon]][Terraform SCA Link]

Terraform module for provisioning an AWS RDS instance on the Modernisation Platform.

This repository is for Modernisation Platform usage only. If you have a suggestion for a change that would benefit multiple teams, please raise an issue with the team [here](https://github.com/ministryofjustice/modernisation-platform/issues/new?template=new-story-template.yml).

## Usage

```hcl

module "rds" {

  source = "github.com/ministryofjustice/modernisation-platform-terraform-rds-instance?ref=2d8e3b21b8f9a0b8acb81597a2d4575068edfede" # v0.6.0

  tags             = local.tags
  application_name = local.application_name

  vpc_id     = data.aws_vpc.shared.id
  subnet_ids = data.aws_subnets.shared_private.ids

  allowed_security_groups = [aws_security_group.application.id]

  db_engine                 = "postgres"
  db_engine_version         = "16"
  db_parameter_group_family = "postgres16"
  db_name                   = "app"
  db_username               = "app_admin"

  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

}

```

<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.secret_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.rds](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.log_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_kinesis_firehose_delivery_stream.xsiam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kinesis_firehose_delivery_stream) | data source |
| [aws_subnets.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Allow major engine version upgrades when changing engine\_version | `bool` | `false` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks permitted to connect to the RDS instance | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | List of security group IDs permitted to connect to the RDS instance | `list(string)` | `[]` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of application | `string` | n/a | yes |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Automatically apply minor engine version upgrades during the maintenance window | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain automated backups. 0 disables automated backups. | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Preferred daily time range for automated backups in UTC (e.g. 03:00-06:00) | `string` | `"03:00-06:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Identifier of the CA certificate for the DB instance. Defaults to rds-ca-rsa4096-g1 (RSA 4096-bit, 100-year validity). Override to rds-ca-ecc384-g1 for ECC or rds-ca-rsa2048-g1 for broader client compatibility. | `string` | `"rds-ca-rsa4096-g1"` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days to retain RDS logs in CloudWatch log groups. | `number` | `30` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Allocated storage in GiB | `number` | `20` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | Database engine type (e.g. postgres, mysql, mariadb, oracle-se2, sqlserver-se) | `string` | n/a | yes |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Database engine version | `string` | n/a | yes |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | RDS instance class | `string` | `"db.t3.medium"` | no |
| <a name="input_db_iops"></a> [db\_iops](#input\_db\_iops) | Provisioned IOPS for the storage. Required for io1 and io2 storage types. Minimum 1000. | `number` | `null` | no |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | Upper limit for storage autoscaling in GiB. Set to 0 to disable autoscaling. | `number` | `0` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the initial database to create. When restoring from a snapshot or creating a replica, this is inherited from the source and can be left null. | `string` | `null` | no |
| <a name="input_db_parameter_group_family"></a> [db\_parameter\_group\_family](#input\_db\_parameter\_group\_family) | Parameter group family used to create the module-managed parameter group with SSL enforcement (e.g. postgres16, mysql8.0, mariadb10.11, sqlserver-se-15.0). Required unless parameter\_group\_name is set. Not applicable to Oracle - configure SSL via the option group instead. | `string` | `null` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Port on which the DB accepts connections. Defaults to 5432 (PostgreSQL). | `number` | `5432` | no |
| <a name="input_db_storage_type"></a> [db\_storage\_type](#input\_db\_storage\_type) | Storage type (gp2, gp3, io1, io2) | `string` | `"gp3"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Master username for the database. Required for new instances and snapshot restores. Inherited from the source instance when replicate\_source\_db is set. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enables deletion protection on the RDS instance | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key used for storage and Secrets Manager encryption. Uses the AWS-managed key if not set. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Preferred weekly time range for maintenance (e.g. Mon:00:00-Mon:03:00) | `string` | `"Mon:00:00-Mon:03:00"` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Interval in seconds for Enhanced Monitoring metrics. Must be 1, 5, 10, 15, 30, or 60. Defaults to 60 (enabled). | `number` | `60` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | ARN of the IAM role that allows RDS to send Enhanced Monitoring metrics to CloudWatch. Required for monitoring. | `string` | n/a | yes |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to deploy the RDS instance across multiple Availability Zones | `bool` | `true` | no |
| <a name="input_opt_in_xsiam_logging"></a> [opt\_in\_xsiam\_logging](#input\_opt\_in\_xsiam\_logging) | If true, forwards RDS CloudWatch logs to XSIAM Cortex via Kinesis Firehose. Requires xsiam\_firehose\_stream\_name and xsiam\_cloudwatch\_role\_arn. | `bool` | `false` | no |
| <a name="input_option_group_name"></a> [option\_group\_name](#input\_option\_group\_name) | Name of the DB option group to associate with the instance (MySQL and Oracle only) | `string` | `null` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of a pre-existing DB parameter group to associate with the instance. When set, the module-managed parameter group (and its SSL enforcement settings) is not created. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Enable Performance Insights for the RDS instance | `bool` | `true` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Retention period for Performance Insights data in days. Must be 7 or 731. | `number` | `7` | no |
| <a name="input_replicate_source_db"></a> [replicate\_source\_db](#input\_replicate\_source\_db) | Identifier or ARN of the source RDS instance to create a read replica from. When set, db\_username, db\_name, and the master password are inherited from the source — Secrets Manager is not provisioned for the replica. | `string` | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip taking a final snapshot before destroying the instance | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Snapshot identifier to restore the instance from. When set, the instance is created from this snapshot instead of a blank database. db\_username must match the snapshot's master username. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of explicit subnet IDs for the DB subnet group. When set, overrides subnet discovery via tags. | `list(string)` | `null` | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Subnet tags used to discover existing subnets for the DB subnet group in the target VPC. Ignored if subnet\_ids is set. | `map(string)` | <pre>{<br/>  "Type": "data"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags to be used by all resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the RDS instance will be deployed | `string` | n/a | yes |
| <a name="input_xsiam_cloudwatch_role_arn"></a> [xsiam\_cloudwatch\_role\_arn](#input\_xsiam\_cloudwatch\_role\_arn) | ARN of the IAM role that allows CloudWatch Logs to write to the Firehose stream. Required when opt\_in\_xsiam\_logging = true. | `string` | `null` | no |
| <a name="input_xsiam_firehose_stream_name"></a> [xsiam\_firehose\_stream\_name](#input\_xsiam\_firehose\_stream\_name) | Name of the Kinesis Firehose delivery stream to send logs to. Required when opt\_in\_xsiam\_logging = true. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

[Standards Link]: https://github-community.service.justice.gov.uk/repository-standards/modernisation-platform-terraform-rds-instance "Repo standards badge."
[Standards Icon]: https://github-community.service.justice.gov.uk/repository-standards/api/modernisation-platform-terraform-rds-instance/badge
[Format Code Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-rds-instance/format-code.yml?labelColor=231f20&style=for-the-badge&label=Formate%20Code
[Format Code Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-rds-instance/actions/workflows/format-code.yml
[Scorecards Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-rds-instance/scorecards.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Scorecards
[Scorecards Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-rds-instance/actions/workflows/scorecards.yml
[SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-rds-instance/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Secure%20Code%20Analysis
[SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-rds-instance/actions/workflows/code-scanning.yml
[Terraform SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-rds-instance/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Terraform%20Static%20Code%20Analysis
[Terraform SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-rds-instance/actions/workflows/terraform-static-analysis.yml
