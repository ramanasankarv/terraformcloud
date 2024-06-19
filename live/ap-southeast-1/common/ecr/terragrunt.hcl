# Automatically load project-level variables
locals {
  # Global variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  app_repository_name = local.app_vars.locals.app_repository_name

  # Tags
  tags = {
    Environment = "common"
    Application = local.appname
  }
  project = local.appname

}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/ecr/aws?version=1.4.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  repository_name                   = local.app_repository_name
  repository_read_write_access_arns = ["arn:aws:iam::${local.account_id}:role/InfrastructureDeployer"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire images older than 30 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Tags
  tags = local.tags
}
