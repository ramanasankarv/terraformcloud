locals {
  # Global variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region

  # Tags
  tags = {
    Environment = local.env
    Application = local.appname
  }
  project      = local.appname
  ci_job_token = "${get_env("CI_JOB_TOKEN", "empty")}" # Used to get internal Ekino terraform modules

  # Terraform source
  repo_url_protocol = replace(local.ci_job_token, "empty", "") == local.ci_job_token ? "git::https://gitlab-ci-token:${local.ci_job_token}@" : "git::https://"
  module_version    = "v0.3.1"

  name_suffix = "${local.appname}-${local.env}"
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
      name        = "ApplicationDeployer${title(local.project)}${title(local.env)}"
      description = "ApplicationDeployer role for ${local.project} app ${local.env} env"
      policies = [
        {
          name = "${local.project}-application-deployer"
          statements = [{
            actions = [
              "ecr:GetAuthorizationToken",
              "ecr:DescribeRepositories",
              "ecr:ListImages",
              "ecr:DescribeImages",
            ]
            resources = [
              "*"
            ]
            },
            {
              actions = [
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:BatchGetImage",
                "ecr:DescribeImageScanFindings",
                "ecr:StartImageScan",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy",
                "ecr:DeleteRepository"
              ]
              resources = [
                "arn:aws:ecr:${local.aws_region}:${local.account_id}:repository/snapshot-cms-dev",
                "arn:aws:ecr:${local.aws_region}:${local.account_id}:repository/snapshot-nextjs-dev"
              ]
            },
            {
              actions = [
                "s3:AbortMultipartUpload",
                "s3:GetObject*",
                "s3:List*",
                "s3:PutObject*",
              ]
              resources = [
                "arn:aws:s3:::${local.project}-*-bucket-frontend-${local.env}",
                "arn:aws:s3:::${local.project}-*-bucket-frontend-${local.env}/*"
              ]
            },
            {
              actions = [
                "cloudfront:ListInvalidations",
                "cloudfront:GetInvalidation",
                "cloudfront:CreateInvalidation"
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
            type        = "AWS"
            identifiers = ["arn:aws:iam::041082409291:role/ekino-tools-gitlab-runner-general-jobs-prod-iamrole"]
          }]
          effect = "Allow"
          conditions = [{
            test     = "StringEquals"
            variable = "sts:ExternalId"
            values = [
              "4LnaTticsknORbvS5yVL4653"
            ]
          }]
        }]
      }
    }
  ]

  tags = local.tags
}
