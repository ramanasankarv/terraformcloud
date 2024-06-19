locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  project     = local.common_vars.locals.project
  customer    = local.common_vars.locals.customer

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env          = local.env_vars.locals.environment

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  ci_job_token = "${get_env("CI_JOB_TOKEN", "empty")}" # Used to get internal Ekino terraform modules

  # Terraform source
  repo_url_protocol = replace(local.ci_job_token, "empty", "") == local.ci_job_token ? "git::https://gitlab-ci-token:${local.ci_job_token}@" : "git::https://"
  module_version    = "v0.3.1"

  name_suffix = "${local.project}-${local.appname}"

  tags = {
    Customer    = local.customer
    Environment = local.env
    Project     = local.project
    Application = local.appname
  }

}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${local.repo_url_protocol}gitlab.ekino.com/systeme/terraform/modules/terraform-module-aws-iam.git//?ref=${local.module_version}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  name_suffix = local.name_suffix
  standalone_roles = [
    {
      name        = "${local.project}-${local.appname}-ecs-execution-role-${local.env}"
      description = "Execution role to allow ecs task to boot"
      policies = [
        {
          name = "${local.project}-${local.appname}-ecs-execution-role-policy"
          statements = [{
            actions = [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            resources = [
              "*"
            ]
            },
            { #### SECRETS ####
              actions = [
                "secretsmanager:GetSecretValue",
                "kms:Decrypt"
              ]
              resources = [
                "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:${local.project}-${local.appname}-*-${local.env}*"
              ]
            },
            { #### Log Group ####
              actions = [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups",
                "logs:PutLogEvents"
              ]
              resources = [
                "*"
              ]
            }
          ]
        }
      ]
      assume_role_policy = {
        statements = [{
          actions = [
            "sts:AssumeRole"
          ]
          principals = [{
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
          }]
          effect     = "Allow"
          conditions = []
        }]
      }
    },
    {
      name        = "${local.project}-${local.appname}-ecs-role-${local.env}"
      description = "Role to for the ECS task"
      policies = [
        #PUT here policy that the ecs task need to assume

      ]
      assume_role_policy = {
        statements = [{
          actions = [
            "sts:AssumeRole"
          ]
          principals = [{
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
          }]
          effect     = "Allow"
          conditions = []
        }]
      }
    },
    {
      name        = "${local.project}-${local.appname}-ecs-execution-api-role-${local.env}"
      description = "Execution role to allow ecs task to boot"
      policies = [
        {
          name = "${local.project}-${local.appname}-ecs-execution-api-role-policy"
          statements = [{
            actions = [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "ssm:GetParameters"
            ]
            resources = [
              "*"
            ]
            },
            { #### S3  ####
              actions = [
                "s3:Get*",
                "s3:List*",
                "s3:Delete*",
                "s3:PutObject*"
              ]
              resources = [
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media",
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media/*"
              ]
            },
            { #### SECRETS ####
              actions = [
                "secretsmanager:GetSecretValue",
                "kms:Decrypt"
              ]
              resources = [
                "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:${local.project}-${local.appname}-*-${local.env}*",
                "arn:aws:kms:${local.aws_region}:${local.account_id}:key/*"
              ]
            },
            { #### Log Group ####
              actions = [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups",
                "logs:PutLogEvents"
              ]
              resources = [
                "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:*-${local.env}*"
              ]
            }
          ]
        }
      ]
      assume_role_policy = {
        statements = [{
          actions = [
            "sts:AssumeRole"
          ]
          principals = [{
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
          }]
          effect     = "Allow"
          conditions = []
        }]
      }
    },
    {
      name        = "${local.project}-${local.appname}-ecs-api-role-${local.env}"
      description = "Role to for the ECS task"
      policies = [
        {
          name = "${local.project}-${local.appname}-ecs-api-role-policy"
          statements = [
            { #### S3  ####
              actions = [
                "s3:Get*",
                "s3:List*",
                "s3:PutObject*"
              ]
              resources = [
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media",
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media/*"
              ]
            }
          ]
        }
      ]
      assume_role_policy = {
        statements = [{
          actions = [
            "sts:AssumeRole"
          ]
          principals = [{
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
          }]
          effect     = "Allow"
          conditions = []
        }]
      }
    },
    {
      name        = "${local.project}-${local.appname}-ecs-execution-cms-role-${local.env}"
      description = "Execution role to allow ecs task to boot"
      policies = [
        {
          name = "${local.project}-${local.appname}-ecs-execution-cms-role-policy"
          statements = [{
            actions = [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "ssm:GetParameters"
            ]
            resources = [
              "*"
            ]
            },
            { #### S3  ####
              actions = [
                "s3:Get*",
                "s3:List*",
                "s3:Delete*",
                "s3:PutObject*"
              ]
              resources = [
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media",
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media/*"
              ]
            },
            { #### SECRETS ####
              actions = [
                "secretsmanager:GetSecretValue",
                "kms:Decrypt"
              ]
              resources = [
                "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:${local.project}-${local.appname}-*-${local.env}*",
                 "arn:aws:kms:ap-southeast-1:851725316377:key/*"
              ]
            },
            { #### Log Group ####
              actions = [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups",
                "logs:PutLogEvents"
              ]
              resources = [
                "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:*-${local.env}*"
              ]
            }
          ]
        }
      ]
      assume_role_policy = {
        statements = [{
          actions = [
            "sts:AssumeRole"
          ]
          principals = [{
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
          }]
          effect     = "Allow"
          conditions = []
        }]
      }
    },
    {
      name        = "${local.project}-${local.appname}-ecs-cms-role-${local.env}"
      description = "Role to for the ECS task"
      policies = [
        {
          name = "${local.project}-${local.appname}-ecs-cms-role-policy"
          statements = [
            { #### S3  ####
              actions = [
                "s3:Get*",
                "s3:List*",
                "s3:Delete*",
                "s3:PutObject*"
              ]
              resources = [
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media",
                "arn:aws:s3:::${local.project}-${local.appname}-${local.env}-media/*"
              ]
            }
          ]
        }
      ]
      assume_role_policy = {
        statements = [{
          actions = [
            "sts:AssumeRole"
          ]
          principals = [{
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
          }]
          effect     = "Allow"
          conditions = []
        }]
      }
    }

  ]

  tags = local.tags
}
