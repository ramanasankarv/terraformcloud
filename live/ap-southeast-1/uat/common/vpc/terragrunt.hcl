# Automatically load project-level variables
locals {
  # Global variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  # Local variables
  vpc_cidrs            = local.env_vars.locals.vpc_cidrs
  vpc_azs              = local.env_vars.locals.vpc_azs
  vpc_public_subnets   = local.env_vars.locals.vpc_public_subnets
  vpc_private_subnets  = local.env_vars.locals.vpc_private_subnets
  vpc_database_subnets = local.env_vars.locals.vpc_database_subnets

  # Tags
  tags = {
    Environment = local.env
    Application = local.appname
  }

  # Variables
  name_suffix = "${local.appname}-${local.env}"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.8.1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


inputs = {
  # General
  name = "vpc-${local.name_suffix}"
  cidr = local.vpc_cidrs
  azs  = local.vpc_azs

  # Subnets
  public_subnet_suffix = "${local.appname}-${local.env}-public"
  public_subnets       = local.vpc_public_subnets

  private_subnet_suffix = "${local.appname}-${local.env}-app"
  private_subnets       = local.vpc_private_subnets

  database_subnet_suffix = "${local.appname}-${local.env}-db"
  database_subnets       = local.vpc_database_subnets

  # Cloudwatch log group and IAM role will be created
  enable_flow_log = true
  # Nat Gateways
  enable_nat_gateway = true
  single_nat_gateway = true
  # Flow Logs
  create_flow_log_cloudwatch_log_group      = true
  create_flow_log_cloudwatch_iam_role       = true
  flow_log_max_aggregation_interval         = 60
  flow_log_cloudwatch_log_group_name_prefix = "${local.appname}-${local.env}-vpc-logs/"
  flow_log_traffic_type                     = "REJECT"

  vpc_flow_log_tags = {
    Name = "vpc-flow-logs-cloudwatch-logs-default"
  }

  # Tags
  tags = local.tags
}
