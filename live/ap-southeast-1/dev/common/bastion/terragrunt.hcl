# Automatically load project-level variables
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  project     = local.common_vars.locals.project
  customer    = local.common_vars.locals.customer

  # Global variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  # VPC
  vpc_subnet_id          = local.env_vars.locals.vpc_public_subnet_id

  # EC2
  ec2_instance_type = local.env_vars.locals.ec2_instance_type
  ec2_ami_id        = local.env_vars.locals.ec2_ami_id




  # Tags
  tags = {
    Environment = local.env
    Application = local.appname
  }

  # Variables
  name_suffix = "${local.appname}-${local.env}"
}

terraform {
  source = "../../../../../modules/bastion"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  # General
  project = local.project
  appname = local.appname
  env     = local.env

  bastion_ami_id        = local.ec2_ami_id
  bastion_instance_type = local.ec2_instance_type
  bastion_subnet_id     = local.vpc_subnet_id
  bastion_vpc_id        = local.env_vars.locals.vpc_id

  # Tags
  tags = local.tags
}
