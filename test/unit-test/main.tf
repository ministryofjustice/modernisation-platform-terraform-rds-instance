
data "aws_vpcs" "shared" {
  provider = aws.core-vpc
  tags = {
    Name = "${local.vpc_name}-${local.environment}"
  }
}

data "aws_subnets" "shared_private" {
  provider = aws.core-vpc
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.shared.ids[0]]
  }
  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-${local.environment}-${local.subnet_set}-data*"]
  }
}

# Create IAM role for RDS monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "testing-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

module "module_test" {
  source           = "../../"
  application_name = local.application_name
  tags             = local.tags

  vpc_id     = data.aws_vpcs.shared.ids[0]
  subnet_ids = data.aws_subnets.shared_private.ids

  db_engine         = "postgres"
  db_engine_version = "16"
  db_name           = "testdb"
  db_username       = "testadmin"

  db_instance_class         = "db.t3.small"
  db_allocated_storage      = 20
  db_storage_type           = "gp3"
  db_parameter_group_family = "postgres16"
  deletion_protection       = false
  skip_final_snapshot       = true
  backup_retention_period   = 1
  monitoring_role_arn       = aws_iam_role.rds_monitoring.arn
}
