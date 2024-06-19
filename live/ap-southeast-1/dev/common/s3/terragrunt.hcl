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

  
  # Variables
  name_suffix = "${local.project}-${local.appname}-${local.env}"

  # Tags
  tags = {
    Customer    = local.common_vars.locals.customer
    Environment = local.env_vars.locals.environment
    Project     = local.common_vars.locals.project
    Application = local.app_vars.locals.appname
  }
}

terraform {
  source = "../../../../../modules/s3"
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
  bucketname              = "${local.name_suffix}-media"
  tags                    = local.tags
  
  # General info
  project = local.project
  env     = local.env

}
