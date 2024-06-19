locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  project     = local.common_vars.locals.project
  customer    = local.common_vars.locals.customer

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  app_vars = read_terragrunt_config(find_in_parent_folders("app.hcl"))
  appname  = local.app_vars.locals.appname

  # Tags
  tags = {
    Customer    = local.customer
    Environment = local.env
    Project     = local.project
    Application = local.appname
  }

  env = local.env_vars.locals.environment

  ecs_service_api_container_image = "851725316377.dkr.ecr.ap-southeast-1.amazonaws.com/snapshot-nextjs-dev:5cfe9760"
}

terraform {
  source = "../../../../../modules/ecs-node-service"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ecs_cluster" {
  config_path = "../ecs-node-cluster"
}

dependency "iam-ecs" {
  config_path = "../iam-ecs"
}

dependency "alb" {
  config_path = "../alb-node"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependencies {
  paths = ["../vpc", "../iam-ecs", "../ecs-node-cluster", "../alb-node"]
}

inputs = {
  # General
  appname = local.appname
  env                = local.env
  tags               = local.tags

  # ECS Global
  ecs_cluster_id            = dependency.ecs_cluster.outputs.ecs_cluster_id
  ecs_lb_arn                = dependency.alb.outputs.alb_arn
  ecs_lb_target_group_arn   = dependency.alb.outputs.alb_target_group_arns[0]
  ecs_service_desired_count = 1
  ecs_vpc_id                = dependency.vpc.outputs.vpc_id

  # Fargate
  ecs_fargate_cpu    = 512
  ecs_fargate_memory = 1024

  # ECS Service Deployment Configuration
  ecs_deployment_max_percent         = 200
  ecs_deployment_min_healthy_percent = 100

  # SG & Subnets
  ecs_service_private_subnets = dependency.vpc.outputs.private_subnets
  alb_security_group_id       = dependency.alb.outputs.alb_security_group_id

  # Container
  ecs_exec_role_arn               = dependency.iam-ecs.outputs.standalone_roles_arn["${local.project}-${local.appname}-ecs-execution-role-${local.env}"]
  ecs_task_role_arn               = dependency.iam-ecs.outputs.standalone_roles_arn["${local.project}-${local.appname}-ecs-role-${local.env}"]
  account_id                      = local.account_id

  ecs_task_definition = [
    {
      name      = "${local.project}-${local.appname}-nextjs-${local.env}"
      image     = local.ecs_service_api_container_image
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name: "url",
          value: "${local.project}-${local.appname}-api-${local.env}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "${local.project}-${local.appname}-nextjs-${local.env}",
          "awslogs-region" : "ap-southeast-1",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "ecs-logs-${local.project}-${local.appname}-nextjs-${local.env}"
        }
      }
    }
  ]
}
