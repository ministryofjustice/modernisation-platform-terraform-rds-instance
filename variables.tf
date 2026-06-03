variable "tags" {
  type        = map(string)
  description = "Common tags to be used by all resources"
}

variable "application_name" {
  type        = string
  description = "Name of application"
}

###############################################################
# Networking
###############################################################

variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS instance will be deployed"
}

variable "subnet_tags" {
  type        = map(string)
  description = "Subnet tags used to discover existing subnets for the DB subnet group in the target VPC. Ignored if subnet_ids is set."
  default = {
    Type = "data"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of explicit subnet IDs for the DB subnet group. When set, overrides subnet discovery via tags."
  default     = null
}

variable "allowed_security_groups" {
  type        = list(string)
  description = "List of security group IDs permitted to connect to the RDS instance"
  default     = []
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks permitted to connect to the RDS instance"
  default     = []
}

###############################################################
# Engine
###############################################################

variable "db_engine" {
  type        = string
  description = "Database engine type (e.g. postgres, mysql, mariadb, oracle-se2, sqlserver-se)"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.medium"
}

variable "db_port" {
  type        = number
  description = "Port on which the DB accepts connections. Defaults to 5432 (PostgreSQL)."
  default     = 5432
}

###############################################################
# Storage
###############################################################

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GiB"
  default     = 20
}

variable "db_max_allocated_storage" {
  type        = number
  description = "Upper limit for storage autoscaling in GiB. Set to 0 to disable autoscaling."
  default     = 0
}

variable "db_storage_type" {
  type        = string
  description = "Storage type (gp2, gp3, io1, io2)"
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.db_storage_type)
    error_message = "db_storage_type must be one of: gp2, gp3, io1, io2."
  }
}

variable "db_iops" {
  type        = number
  description = "Provisioned IOPS for the storage. Required for io1 and io2 storage types. Minimum 1000."
  default     = null

  validation {
    condition     = var.db_iops == null || try(var.db_iops >= 1000, false)
    error_message = "db_iops must be at least 1000 when specified."
  }
}

###############################################################
# Database
###############################################################

variable "db_name" {
  type        = string
  description = "Name of the initial database to create. When restoring from a snapshot or creating a replica, this is inherited from the source and can be left null."
  default     = null
}

variable "db_username" {
  type        = string
  description = "Master username for the database. Required for new instances and snapshot restores. Inherited from the source instance when replicate_source_db is set."
  default     = null
}

###############################################################
# Encryption
###############################################################

variable "kms_key_id" {
  type        = string
  description = "ARN of the KMS key used for storage and Secrets Manager encryption. Uses the AWS-managed key if not set."
  default     = null
}

###############################################################
# Availability & maintenance
###############################################################

variable "multi_az" {
  type        = bool
  description = "Whether to deploy the RDS instance across multiple Availability Zones"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Enables deletion protection on the RDS instance"
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether to skip taking a final snapshot before destroying the instance"
  default     = false
}

###############################################################
# Snapshot & replication
###############################################################

variable "snapshot_identifier" {
  type        = string
  description = "Snapshot identifier to restore the instance from. When set, the instance is created from this snapshot instead of a blank database. db_username must match the snapshot's master username."
  default     = null
}

variable "replicate_source_db" {
  type        = string
  description = "Identifier or ARN of the source RDS instance to create a read replica from. When set, db_username, db_name, and the master password are inherited from the source — Secrets Manager is not provisioned for the replica."
  default     = null
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days to retain automated backups. 0 disables automated backups."
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "Preferred daily time range for automated backups in UTC (e.g. 03:00-06:00)"
  default     = "03:00-06:00"
}

variable "maintenance_window" {
  type        = string
  description = "Preferred weekly time range for maintenance (e.g. Mon:00:00-Mon:03:00)"
  default     = "Mon:00:00-Mon:03:00"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Automatically apply minor engine version upgrades during the maintenance window"
  default     = true
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Allow major engine version upgrades when changing engine_version"
  default     = false
}

###############################################################
# Monitoring & performance
###############################################################

variable "performance_insights_enabled" {
  type        = bool
  description = "Enable Performance Insights for the RDS instance"
  default     = true
}

variable "performance_insights_retention_period" {
  type        = number
  description = "Retention period for Performance Insights data in days. Must be 7 or 731."
  default     = 7
}

variable "monitoring_interval" {
  type        = number
  description = "Interval in seconds for Enhanced Monitoring metrics. Must be 1, 5, 10, 15, 30, or 60. Defaults to 60 (enabled)."
  default     = 60
}

variable "monitoring_role_arn" {
  type        = string
  description = "ARN of the IAM role that allows RDS to send Enhanced Monitoring metrics to CloudWatch. Required for monitoring."
}

###############################################################
# Parameter / option groups & certificates
###############################################################

variable "parameter_group_name" {
  type        = string
  description = "Name of a pre-existing DB parameter group to associate with the instance. When set, the module-managed parameter group (and its SSL enforcement settings) is not created."
  default     = null
}

variable "db_parameter_group_family" {
  type        = string
  description = "Parameter group family used to create the module-managed parameter group with SSL enforcement (e.g. postgres16, mysql8.0, mariadb10.11, sqlserver-se-15.0). Required unless parameter_group_name is set. Not applicable to Oracle - configure SSL via the option group instead."
  default     = null
}

variable "option_group_name" {
  type        = string
  description = "Name of the DB option group to associate with the instance (MySQL and Oracle only)"
  default     = null
}

variable "ca_cert_identifier" {
  type        = string
  description = "Identifier of the CA certificate for the DB instance. Defaults to rds-ca-rsa4096-g1 (RSA 4096-bit, 100-year validity). Override to rds-ca-ecc384-g1 for ECC or rds-ca-rsa2048-g1 for broader client compatibility."
  default     = "rds-ca-rsa4096-g1"
}

###############################################################
# Logging & XSIAM
###############################################################

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "Number of days to retain RDS logs in CloudWatch log groups."
  default     = 30
}

variable "opt_in_xsiam_logging" {
  type        = bool
  description = "If true, forwards RDS CloudWatch logs to XSIAM Cortex via Kinesis Firehose. Requires xsiam_firehose_stream_name and xsiam_cloudwatch_role_arn."
  default     = false
}

variable "xsiam_firehose_stream_name" {
  type        = string
  description = "Name of the Kinesis Firehose delivery stream to send logs to. Required when opt_in_xsiam_logging = true."
  default     = null
}

variable "xsiam_cloudwatch_role_arn" {
  type        = string
  description = "ARN of the IAM role that allows CloudWatch Logs to write to the Firehose stream. Required when opt_in_xsiam_logging = true."
  default     = null
}

