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
  alb_acm_certificate_arn       = local.env_vars.locals.alb_acm_certificate_arn
  route53_public_hosted_zone_id = local.env_vars.locals.route53_public_hosted_zone_id
  alb_hostname                  = local.env_vars.locals.alb_hostname
}

terraform {
  source = "../../../../../modules/alb"
}

dependency "vpc" {
  config_path = "../vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  alb_name                = "${local.project}-${local.appname}-alb-${local.env}"
  sg_name                 = "${local.project}-${local.appname}-alb-sg-${local.env}"
  tg_name                 = "${local.project}-${local.appname}-tg-${local.env}"
  tags                    = local.tags
  vpc_id                  = dependency.vpc.outputs.vpc_id
  public_subnets          = dependency.vpc.outputs.public_subnets
  alb_acm_certificate_arn = local.alb_acm_certificate_arn
  route53_record_name     = "${local.env}-cms.snapshot-albbmq2.com"
  route53_public_host_id  = local.route53_public_hosted_zone_id
  appname                 = local.appname
  backend_port            = 80

  # Health check
  healthcheck_path    = "/healthcheck.html"
  whitelisted_ip_list = ["185.15.129.9/32","106.51.228.78/32","203.127.235.0/24","202.136.165.130/32","203.127.235.36/30"]
  # General info
  project = local.project
  env     = local.env
}
