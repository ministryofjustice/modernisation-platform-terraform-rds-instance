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

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0  |
| <a name="requirement_random"></a> [random](#requirement_random)          | ~> 3.0  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | ~> 6.0  |
| <a name="provider_random"></a> [random](#provider_random) | ~> 3.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                 | resource    |
| [aws_cloudwatch_log_subscription_filter.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter)     | resource    |
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)                                                   | resource    |
| [aws_db_parameter_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group)                                     | resource    |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)                                           | resource    |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                               | resource    |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)               | resource    |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                             | resource    |
| [aws_vpc_security_group_ingress_rule.allowed_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource    |
| [aws_vpc_security_group_ingress_rule.allowed_sgs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)   | resource    |
| [random_id.secret_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                     | resource    |
| [random_password.rds](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                                   | resource    |
| [random_string.log_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                | resource    |
| [aws_kinesis_firehose_delivery_stream.xsiam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kinesis_firehose_delivery_stream)    | data source |
| [aws_subnets.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets)                                                        | data source |

## Inputs

| Name                                                                                                                                             | Description                                                                                                                                                                                                                                                                     | Type           | Default                                | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------------------------------- | :------: |
| <a name="input_allow_major_version_upgrade"></a> [allow_major_version_upgrade](#input_allow_major_version_upgrade)                               | Allow major engine version upgrades when changing engine_version                                                                                                                                                                                                                | `bool`         | `false`                                |    no    |
| <a name="input_allowed_cidr_blocks"></a> [allowed_cidr_blocks](#input_allowed_cidr_blocks)                                                       | List of CIDR blocks permitted to connect to the RDS instance                                                                                                                                                                                                                    | `list(string)` | `[]`                                   |    no    |
| <a name="input_allowed_security_groups"></a> [allowed_security_groups](#input_allowed_security_groups)                                           | List of security group IDs permitted to connect to the RDS instance                                                                                                                                                                                                             | `list(string)` | `[]`                                   |    no    |
| <a name="input_application_name"></a> [application_name](#input_application_name)                                                                | Name of application                                                                                                                                                                                                                                                             | `string`       | n/a                                    |   yes    |
| <a name="input_auto_minor_version_upgrade"></a> [auto_minor_version_upgrade](#input_auto_minor_version_upgrade)                                  | Automatically apply minor engine version upgrades during the maintenance window                                                                                                                                                                                                 | `bool`         | `true`                                 |    no    |
| <a name="input_backup_retention_period"></a> [backup_retention_period](#input_backup_retention_period)                                           | Number of days to retain automated backups. 0 disables automated backups.                                                                                                                                                                                                       | `number`       | `7`                                    |    no    |
| <a name="input_backup_window"></a> [backup_window](#input_backup_window)                                                                         | Preferred daily time range for automated backups in UTC (e.g. 03:00-06:00)                                                                                                                                                                                                      | `string`       | `"03:00-06:00"`                        |    no    |
| <a name="input_ca_cert_identifier"></a> [ca_cert_identifier](#input_ca_cert_identifier)                                                          | Identifier of the CA certificate for the DB instance. Defaults to rds-ca-rsa4096-g1 (RSA 4096-bit, 100-year validity). Override to rds-ca-ecc384-g1 for ECC or rds-ca-rsa2048-g1 for broader client compatibility.                                                              | `string`       | `"rds-ca-rsa4096-g1"`                  |    no    |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch_log_retention_days](#input_cloudwatch_log_retention_days)                         | Number of days to retain RDS logs in CloudWatch log groups.                                                                                                                                                                                                                     | `number`       | `30`                                   |    no    |
| <a name="input_db_allocated_storage"></a> [db_allocated_storage](#input_db_allocated_storage)                                                    | Allocated storage in GiB                                                                                                                                                                                                                                                        | `number`       | `20`                                   |    no    |
| <a name="input_db_engine"></a> [db_engine](#input_db_engine)                                                                                     | Database engine type (e.g. postgres, mysql, mariadb, oracle-se2, sqlserver-se)                                                                                                                                                                                                  | `string`       | n/a                                    |   yes    |
| <a name="input_db_engine_version"></a> [db_engine_version](#input_db_engine_version)                                                             | Database engine version                                                                                                                                                                                                                                                         | `string`       | n/a                                    |   yes    |
| <a name="input_db_instance_class"></a> [db_instance_class](#input_db_instance_class)                                                             | RDS instance class                                                                                                                                                                                                                                                              | `string`       | `"db.t3.medium"`                       |    no    |
| <a name="input_db_iops"></a> [db_iops](#input_db_iops)                                                                                           | Provisioned IOPS for the storage. Required for io1 and io2 storage types. Minimum 1000.                                                                                                                                                                                         | `number`       | `null`                                 |    no    |
| <a name="input_db_max_allocated_storage"></a> [db_max_allocated_storage](#input_db_max_allocated_storage)                                        | Upper limit for storage autoscaling in GiB. Set to 0 to disable autoscaling.                                                                                                                                                                                                    | `number`       | `0`                                    |    no    |
| <a name="input_db_name"></a> [db_name](#input_db_name)                                                                                           | Name of the initial database to create. When restoring from a snapshot or creating a replica, this is inherited from the source and can be left null.                                                                                                                           | `string`       | `null`                                 |    no    |
| <a name="input_db_parameter_group_family"></a> [db_parameter_group_family](#input_db_parameter_group_family)                                     | Parameter group family used to create the module-managed parameter group with SSL enforcement (e.g. postgres16, mysql8.0, mariadb10.11, sqlserver-se-15.0). Required unless parameter_group_name is set. Not applicable to Oracle - configure SSL via the option group instead. | `string`       | `null`                                 |    no    |
| <a name="input_db_port"></a> [db_port](#input_db_port)                                                                                           | Port on which the DB accepts connections. Defaults to 5432 (PostgreSQL).                                                                                                                                                                                                        | `number`       | `5432`                                 |    no    |
| <a name="input_db_storage_type"></a> [db_storage_type](#input_db_storage_type)                                                                   | Storage type (gp2, gp3, io1, io2)                                                                                                                                                                                                                                               | `string`       | `"gp3"`                                |    no    |
| <a name="input_db_username"></a> [db_username](#input_db_username)                                                                               | Master username for the database. Required for new instances and snapshot restores. Inherited from the source instance when replicate_source_db is set.                                                                                                                         | `string`       | `null`                                 |    no    |
| <a name="input_deletion_protection"></a> [deletion_protection](#input_deletion_protection)                                                       | Enables deletion protection on the RDS instance                                                                                                                                                                                                                                 | `bool`         | `true`                                 |    no    |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id)                                                                                  | ARN of the KMS key used for storage and Secrets Manager encryption. Uses the AWS-managed key if not set.                                                                                                                                                                        | `string`       | `null`                                 |    no    |
| <a name="input_maintenance_window"></a> [maintenance_window](#input_maintenance_window)                                                          | Preferred weekly time range for maintenance (e.g. Mon:00:00-Mon:03:00)                                                                                                                                                                                                          | `string`       | `"Mon:00:00-Mon:03:00"`                |    no    |
| <a name="input_monitoring_interval"></a> [monitoring_interval](#input_monitoring_interval)                                                       | Interval in seconds for Enhanced Monitoring metrics. Must be 1, 5, 10, 15, 30, or 60. Defaults to 60 (enabled).                                                                                                                                                                 | `number`       | `60`                                   |    no    |
| <a name="input_monitoring_role_arn"></a> [monitoring_role_arn](#input_monitoring_role_arn)                                                       | ARN of the IAM role that allows RDS to send Enhanced Monitoring metrics to CloudWatch. Required for monitoring.                                                                                                                                                                 | `string`       | n/a                                    |   yes    |
| <a name="input_multi_az"></a> [multi_az](#input_multi_az)                                                                                        | Whether to deploy the RDS instance across multiple Availability Zones                                                                                                                                                                                                           | `bool`         | `true`                                 |    no    |
| <a name="input_opt_in_xsiam_logging"></a> [opt_in_xsiam_logging](#input_opt_in_xsiam_logging)                                                    | If true, forwards RDS CloudWatch logs to XSIAM Cortex via Kinesis Firehose. Requires xsiam_firehose_stream_name and xsiam_cloudwatch_role_arn.                                                                                                                                  | `bool`         | `false`                                |    no    |
| <a name="input_option_group_name"></a> [option_group_name](#input_option_group_name)                                                             | Name of the DB option group to associate with the instance (MySQL and Oracle only)                                                                                                                                                                                              | `string`       | `null`                                 |    no    |
| <a name="input_parameter_group_name"></a> [parameter_group_name](#input_parameter_group_name)                                                    | Name of a pre-existing DB parameter group to associate with the instance. When set, the module-managed parameter group (and its SSL enforcement settings) is not created.                                                                                                       | `string`       | `null`                                 |    no    |
| <a name="input_performance_insights_enabled"></a> [performance_insights_enabled](#input_performance_insights_enabled)                            | Enable Performance Insights for the RDS instance                                                                                                                                                                                                                                | `bool`         | `true`                                 |    no    |
| <a name="input_performance_insights_retention_period"></a> [performance_insights_retention_period](#input_performance_insights_retention_period) | Retention period for Performance Insights data in days. Must be 7 or 731.                                                                                                                                                                                                       | `number`       | `7`                                    |    no    |
| <a name="input_replicate_source_db"></a> [replicate_source_db](#input_replicate_source_db)                                                       | Identifier or ARN of the source RDS instance to create a read replica from. When set, db_username, db_name, and the master password are inherited from the source — Secrets Manager is not provisioned for the replica.                                                         | `string`       | `null`                                 |    no    |
| <a name="input_skip_final_snapshot"></a> [skip_final_snapshot](#input_skip_final_snapshot)                                                       | Whether to skip taking a final snapshot before destroying the instance                                                                                                                                                                                                          | `bool`         | `false`                                |    no    |
| <a name="input_snapshot_identifier"></a> [snapshot_identifier](#input_snapshot_identifier)                                                       | Snapshot identifier to restore the instance from. When set, the instance is created from this snapshot instead of a blank database. db_username must match the snapshot's master username.                                                                                      | `string`       | `null`                                 |    no    |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)                                                                                  | List of explicit subnet IDs for the DB subnet group. When set, overrides subnet discovery via tags.                                                                                                                                                                             | `list(string)` | `null`                                 |    no    |
| <a name="input_subnet_tags"></a> [subnet_tags](#input_subnet_tags)                                                                               | Subnet tags used to discover existing subnets for the DB subnet group in the target VPC. Ignored if subnet_ids is set.                                                                                                                                                          | `map(string)`  | <pre>{<br/> "Type": "data"<br/>}</pre> |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                    | Common tags to be used by all resources                                                                                                                                                                                                                                         | `map(string)`  | n/a                                    |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                                              | VPC ID where the RDS instance will be deployed                                                                                                                                                                                                                                  | `string`       | n/a                                    |   yes    |
| <a name="input_xsiam_cloudwatch_role_arn"></a> [xsiam_cloudwatch_role_arn](#input_xsiam_cloudwatch_role_arn)                                     | ARN of the IAM role that allows CloudWatch Logs to write to the Firehose stream. Required when opt_in_xsiam_logging = true.                                                                                                                                                     | `string`       | `null`                                 |    no    |
| <a name="input_xsiam_firehose_stream_name"></a> [xsiam_firehose_stream_name](#input_xsiam_firehose_stream_name)                                  | Name of the Kinesis Firehose delivery stream to send logs to. Required when opt_in_xsiam_logging = true.                                                                                                                                                                        | `string`       | `null`                                 |    no    |

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
