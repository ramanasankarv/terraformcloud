locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  project     = local.common_vars.locals.project
  customer    = local.common_vars.locals.customer

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname = local.app_vars.locals.appname

  # Tags
  tags = {
    Customer    = local.customer
    Environment = local.env
    Project     = local.project
    Application = local.appname
  }

  env = local.env_vars.locals.environment

}

terraform {
  source = "../../../../../modules/ecs-cluster"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  cluster_name = "${local.project}-${local.appname}-ecs-cluster-${local.env}"
  tags               = local.tags

}
