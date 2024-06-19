locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  project     = local.common_vars.locals.project
  customer    = local.common_vars.locals.customer

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname      = local.app_vars.locals.appname

  # Tags
  tags = {
    Customer    = local.customer
    Environment = local.env
    Project     = local.project
    Application = local.appname
  }

  env                           = local.env_vars.locals.environment

}

terraform {
  source = "../../../../../modules/opensearch"
}

dependency "vpc" {
  config_path = "../vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  opensearch_name         = "${local.project}-${local.appname}-opensearch-${local.env}"
  sg_name                 = "${local.project}-${local.appname}-opensearch-sg-${local.env}"
  tg_name                 = "${local.project}-${local.appname}-opensearch-tg-${local.env}"
  tags                    = local.tags
  vpc_id                  = dependency.vpc.outputs.vpc_id
  public_subnets          = dependency.vpc.outputs.public_subnets
  appname                 = local.appname
  
  # Health check
  whitelisted_ip_list = ["185.15.129.9/32","106.51.228.78/32","203.127.235.0/24","202.136.165.130/32","203.127.235.36/30"]
  
  # General info
  project = local.project
  env     = local.env
}
