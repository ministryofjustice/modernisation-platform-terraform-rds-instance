###############################################################
# Locals
###############################################################

locals {
  # SSL-enforcement parameter per engine type.
  # Oracle requires option-group-based SSL configuration and is intentionally
  # excluded here — see the oracle_ssl_note below.
  ssl_parameters = {
    "postgres"      = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]
    "mysql"         = [{ name = "require_secure_transport", value = "ON", apply_method = "immediate" }]
    "mariadb"       = [{ name = "require_secure_transport", value = "ON", apply_method = "immediate" }]
    "sqlserver-se"  = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]
    "sqlserver-ee"  = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]
    "sqlserver-ex"  = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]
    "sqlserver-web" = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]
  }

  ssl_params = lookup(local.ssl_parameters, var.db_engine, [])

  # When the caller supplies their own parameter group, respect it.
  # Otherwise, use the module-managed one (requires db_parameter_group_family).
  effective_parameter_group_name = (
    var.parameter_group_name != null
    ? var.parameter_group_name
    : (var.db_parameter_group_family != null ? aws_db_parameter_group.rds[0].name : null)
  )

  # Use explicit subnet IDs if provided; otherwise discover via tags.
  effective_subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.rds.ids

  # CloudWatch log exports per engine type.
  db_log_export_mappings = {
    "postgres"      = ["postgresql", "upgrade"]
    "mysql"         = ["error", "general", "slowquery"]
    "mariadb"       = ["error", "general", "slowquery"]
    "oracle-se2"    = ["alert", "audit", "listener"]
    "oracle-ee"     = ["alert", "audit", "listener"]
    "sqlserver-se"  = ["agent", "error"]
    "sqlserver-ee"  = ["agent", "error"]
    "sqlserver-ex"  = ["agent", "error"]
    "sqlserver-web" = ["agent", "error"]
  }

  log_exports = lookup(local.db_log_export_mappings, var.db_engine, [])
}

###############################################################
# Parameter group (SSL enforcement)
###############################################################

# Created only when the caller provides a family and has not supplied their own
# parameter group name. Enforces encrypted connections at the database level.
resource "aws_db_parameter_group" "rds" {
  count = var.parameter_group_name == null && var.db_parameter_group_family != null ? 1 : 0

  name        = "${var.application_name}-rds"
  family      = var.db_parameter_group_family
  description = "${var.application_name} RDS parameter group - SSL/TLS enforcement enabled"

  dynamic "parameter" {
    for_each = local.ssl_params
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################
# Security group
###############################################################

resource "aws_security_group" "rds" {
  name        = "${var.application_name}-rds"
  description = "Controls access to the ${var.application_name} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allowed_sgs" {
  for_each = toset(var.allowed_security_groups)

  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = each.value
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  description                  = "Allow inbound DB traffic from security group ${each.value}"

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allowed_cidrs" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = each.value
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
  description       = "Allow inbound DB traffic from CIDR ${each.value}"

  tags = var.tags
}

###############################################################
# Subnet group
###############################################################

data "aws_subnets" "rds" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = var.subnet_tags
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.application_name}-rds"
  subnet_ids = local.effective_subnet_ids

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds" }
  )
}

###############################################################
# Master password – randomly generated, stored in Secrets Manager
# Skipped for read replicas (credentials are inherited from source)
###############################################################

resource "random_password" "rds" {
  count = var.replicate_source_db == null ? 1 : 0

  length           = 30
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "random_id" "secret_suffix" {
  count = var.replicate_source_db == null ? 1 : 0

  byte_length = 4
}

resource "aws_secretsmanager_secret" "rds" {
  count = var.replicate_source_db == null ? 1 : 0

  name                    = "${var.application_name}-rds-master-password-${random_id.secret_suffix[0].hex}"
  description             = "RDS master password for the ${var.application_name} instance"
  recovery_window_in_days = 7
  kms_key_id              = var.kms_key_id

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds-master-password" }
  )
}

resource "aws_secretsmanager_secret_version" "rds" {
  count = var.replicate_source_db == null ? 1 : 0

  secret_id = aws_secretsmanager_secret.rds[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds[0].result
    engine   = var.db_engine
    host     = aws_db_instance.rds.address
    port     = aws_db_instance.rds.port
    dbname   = aws_db_instance.rds.db_name
  })
}

###############################################################
# RDS instance
###############################################################

resource "aws_db_instance" "rds" {
  identifier = "${var.application_name}-rds"

  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  iops                  = var.db_iops
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? random_password.rds[0].result : null
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = var.multi_az
  publicly_accessible = false
  deletion_protection = var.deletion_protection

  snapshot_identifier = var.snapshot_identifier
  replicate_source_db = var.replicate_source_db

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.application_name}-rds-final-snapshot"

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  enabled_cloudwatch_logs_exports = local.log_exports

  copy_tags_to_snapshot = true
  parameter_group_name  = local.effective_parameter_group_name
  option_group_name     = var.option_group_name
  ca_cert_identifier    = var.ca_cert_identifier

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds" }
  )

  depends_on = [aws_cloudwatch_log_group.rds]

  lifecycle {
    ignore_changes = [password, engine_version]

    precondition {
      condition     = !contains(["io1", "io2"], var.db_storage_type) || var.db_iops != null
      error_message = "db_iops must be set when db_storage_type is io1 or io2."
    }

    precondition {
      condition     = var.db_iops == null || contains(["io1", "io2"], var.db_storage_type)
      error_message = "db_iops can only be used with io1 or io2 storage types."
    }

    precondition {
      condition     = var.replicate_source_db == null || var.snapshot_identifier == null
      error_message = "replicate_source_db and snapshot_identifier cannot both be set."
    }

    precondition {
      condition     = var.replicate_source_db != null || var.db_username != null
      error_message = "db_username is required when not creating a read replica."
    }
  }
}

###############################################################
# CloudWatch log groups
###############################################################

# Random Log Suffix to ensure file name clashes don't occur
resource "random_string" "log_suffix" {
  length  = 8
  special = false
}

resource "aws_cloudwatch_log_group" "rds" {
  for_each = toset(local.log_exports)

  name              = "/aws/rds/instance/${var.application_name}-rds/${each.value}-${random_string.log_suffix.result}"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.kms_key_id

  tags = merge(
    var.tags,
    { "Name" = "/aws/rds/instance/${var.application_name}-rds/${each.value}-${random_string.log_suffix.result}" }
  )
}

###############################################################
# XSIAM log forwarding (opt-in)
###############################################################

data "aws_kinesis_firehose_delivery_stream" "xsiam" {
  count = var.opt_in_xsiam_logging ? 1 : 0
  name  = var.xsiam_firehose_stream_name
}

resource "aws_cloudwatch_log_subscription_filter" "rds" {
  for_each = var.opt_in_xsiam_logging ? toset(local.log_exports) : toset([])

  name            = "${var.application_name}-rds-${each.value}-to-xsiam"
  log_group_name  = aws_cloudwatch_log_group.rds[each.value].name
  filter_pattern  = ""
  destination_arn = data.aws_kinesis_firehose_delivery_stream.xsiam[0].arn
  role_arn        = var.xsiam_cloudwatch_role_arn

  depends_on = [aws_cloudwatch_log_group.rds]
}
