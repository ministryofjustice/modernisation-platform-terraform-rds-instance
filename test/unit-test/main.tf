
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
  tags = {
    SubnetSet = local.subnet_set
    Type      = "private"
  }
}

module "module_test" {
  source           = "../../"
  application_name = local.application_name
  tags             = local.tags

  vpc_id = data.aws_vpcs.shared.ids[0]
  subnet_tags = {
    SubnetSet = local.subnet_set
    Type      = "private"
  }

  db_engine         = "postgres"
  db_engine_version = "16"
  db_name           = "testdb"
  db_username       = "testadmin"

  db_instance_class         = "db.t3.small"
  db_allocated_storage      = 20
  db_parameter_group_family = "postgres16"
  deletion_protection       = false
  skip_final_snapshot       = true
  backup_retention_period   = 1
}
