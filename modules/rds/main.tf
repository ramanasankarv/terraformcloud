
locals {
  create_db_subnet_group    = var.create_db_subnet_group 
  create_db_parameter_group = var.create_db_parameter_group 
  create_db_instance        = var.create_db_instance

  create_random_password = local.create_db_instance && var.create_random_password
  password               = random_password.db_password.result

  #db_subnet_group_name    = var.create_db_subnet_group ? module.db_subnet_group.db_subnet_group_id : var.db_subnet_group_name
  parameter_group_name_id = var.create_db_parameter_group ? module.db_parameter_group.db_parameter_group_id : var.parameter_group_name

  create_db_option_group = var.create_db_option_group && var.engine != "postgres"
  option_group           = local.create_db_option_group ? module.db_option_group.db_option_group_id : var.option_group_name
}

resource "random_password" "db_password" {
  length  = var.random_password_length
  special = false
}

resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds_password-${var.env}"
  description = "rds Password"  
  recovery_window_in_days = 0  
  tags = {
    Name        = "rds_password"
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = local.password
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.appname}-rds-${var.env}"
  description = "Security group for rds with custom ports open within VPC, and mariaDB publicly open"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MariaDB ports"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks    = [var.vpc_cidrs]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   
  tags = {
    Name        = "${var.project}-${var.appname}-rds-${var.env}"
    Environment = var.env
    Project     = var.project
    Customer    = var.appname
  }  
}

resource "aws_db_subnet_group" "fiitjee_mariadb" {
  name     = "${var.project}-mariadb-${var.env}"

  tags = { Name = "${var.project} ${var.env} MariaDB" }

  subnet_ids = var.subnet_ids
}

module "db_parameter_group" {
  source  = "terraform-aws-modules/rds/aws//modules/db_parameter_group"
  version = "5.1.1"

  name            = coalesce(var.parameter_group_name, var.identifier)
  use_name_prefix = var.parameter_group_use_name_prefix
  description     = var.parameter_group_description
  family          = var.family

  parameters = var.parameters

  tags = merge(var.tags, var.db_parameter_group_tags)
}

module "db_option_group" {
  source  = "terraform-aws-modules/rds/aws//modules/db_option_group"
  version = "5.1.1"

  name                     = coalesce(var.option_group_name, var.identifier)
  use_name_prefix          = var.option_group_use_name_prefix
  option_group_description = var.option_group_description
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  options = var.options

  timeouts = var.option_group_timeouts

  tags = merge(var.tags, var.db_option_group_tags)
}

module "db_instance" {
  source  = "terraform-aws-modules/rds/aws//modules/db_instance"
  version = "5.1.1"

  create                = local.create_db_instance
  identifier            = var.identifier
  use_identifier_prefix = var.instance_use_identifier_prefix

  backup_retention_period   = 10                                          # how long you’re going to keep your backups
  
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  license_model     = var.license_model

  db_name                             = var.db_name
  username                            = var.username
  password                            = local.password
  port                                = var.port
  domain                              = var.domain
  domain_iam_role_name                = var.domain_iam_role_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = [aws_security_group.rds.id]
  
  db_subnet_group_name   = "${aws_db_subnet_group.fiitjee_mariadb.id}"
  parameter_group_name   = local.parameter_group_name_id
  option_group_name      = local.option_group
  network_type           = var.network_type

  availability_zone   = var.availability_zone
  multi_az            = var.multi_az
  iops                = var.iops
  publicly_accessible = var.publicly_accessible
  ca_cert_identifier  = var.ca_cert_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window

  snapshot_identifier              = var.snapshot_identifier
  copy_tags_to_snapshot            = var.copy_tags_to_snapshot
  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  replicate_source_db             = var.replicate_source_db
  replica_mode                    = var.replica_mode
  backup_window                   = var.backup_window
  max_allocated_storage           = var.max_allocated_storage
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  monitoring_role_name            = var.monitoring_role_name
  monitoring_role_use_name_prefix = var.monitoring_role_use_name_prefix
  monitoring_role_description     = var.monitoring_role_description
  create_monitoring_role          = var.create_monitoring_role

  character_set_name = var.character_set_name
  timezone           = var.timezone

  enabled_cloudwatch_logs_exports        = var.enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id

  timeouts = var.timeouts

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups

  restore_to_point_in_time = var.restore_to_point_in_time
  s3_import                = var.s3_import

  tags = merge(var.tags, var.db_instance_tags)
}

