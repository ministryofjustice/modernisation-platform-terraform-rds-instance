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
  description = "${var.application_name} RDS parameter group – SSL/TLS enforcement enabled"

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
  subnet_ids = data.aws_subnets.rds.ids

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds" }
  )
}

###############################################################
# Master password – randomly generated, stored in Secrets Manager
###############################################################

resource "random_password" "rds" {
  length           = 30
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "aws_secretsmanager_secret" "rds" {
  name                    = "${var.application_name}-rds-master-password"
  description             = "RDS master password for the ${var.application_name} instance"
  recovery_window_in_days = 7
  kms_key_id              = var.kms_key_id

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds-master-password" }
  )
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds.result
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
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.db_username
  password = random_password.rds.result
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = var.multi_az
  publicly_accessible = false
  deletion_protection = var.deletion_protection

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
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  copy_tags_to_snapshot = true
  parameter_group_name  = local.effective_parameter_group_name
  option_group_name     = var.option_group_name
  ca_cert_identifier    = var.ca_cert_identifier

  tags = merge(
    var.tags,
    { "Name" = "${var.application_name}-rds" }
  )

  lifecycle {
    ignore_changes = [password, engine_version]
  }
}
