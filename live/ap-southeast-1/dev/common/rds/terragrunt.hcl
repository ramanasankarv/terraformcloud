locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  project     = local.common_vars.locals.project
  customer    = local.common_vars.locals.customer

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env          = local.env_vars.locals.environment

  app_vars     = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname      = local.app_vars.locals.appname

  vpc_cidrs    = local.env_vars.locals.vpc_cidrs

  # RDS
  #allowed_security_groups = local.env_vars.locals.rds_allowed_security_groups
  #allowed_cidr_blocks     = local.env_vars.locals.rds_allowed_cidr_blocks
  rds_instance_class      = local.env_vars.locals.rds_instance_class
  rds_engine_version      = local.env_vars.locals.rds_engine_version
  rds_engine              = local.env_vars.locals.rds_engine
  rds_allocated_storage   = local.env_vars.locals.rds_allocated_storage
 

  # Variables
  name_suffix = "${local.project}-${local.project}-${local.env}"

  # Tags
  tags = {
    Customer    = local.common_vars.locals.customer
    Environment = local.env_vars.locals.environment
    Project     = local.common_vars.locals.project
    Application = local.app_vars.locals.appname
  }
}

terraform {
  source = "../../../../../modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  #TO BE DEFINED
  identifier              = "${local.project}-web-db-${local.env}"
  tags                    = local.tags
  engine                  = local.rds_engine
  engine_version          = local.rds_engine_version
  db_name                 = local.project
  instance_class          = local.rds_instance_class
  allocated_storage       = local.rds_allocated_storage
  vpc_id                  = dependency.vpc.outputs.vpc_id
  vpc_cidrs               = local.vpc_cidrs
  subnet_ids              = dependency.vpc.outputs.database_subnets
  appname                 = local.appname
  backend_port            = 3306

  # General info
  project = local.project
  env     = local.env

}
