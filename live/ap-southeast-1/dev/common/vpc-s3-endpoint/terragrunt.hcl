locals {
  # Global variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  # Tags
  tags = {
    Environment = local.env
    Application = local.appname
  }

}

terraform {
  source = "../../../../../modules/vpc-s3-endpoint"
}

dependency "vpc" {
  config_path = "../vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  # General 
  vpc_id          = dependency.vpc.outputs.vpc_id
  route_table_ids = dependency.vpc.outputs.private_route_table_ids


  # Tags
  tags = local.tags
}
