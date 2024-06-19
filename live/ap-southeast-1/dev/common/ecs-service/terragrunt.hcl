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

  ecs_service_api_container_image = "851725316377.dkr.ecr.ap-southeast-1.amazonaws.com/snapshot-cms-dev:5cfe9760"
}

terraform {
  source = "../../../../../modules/ecs-service"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ecs_cluster" {
  config_path = "../ecs-node-cluster"
}

dependency "ecs_cms_cluster" {
  config_path = "../ecs-cluster"
}
dependency "iam-ecs" {
  config_path = "../iam-ecs"
}

dependency "alb" {
  config_path = "../alb"
}

dependency "alb-api" {
  config_path = "../alb-api"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependencies {
  paths = ["../vpc", "../iam-ecs", "../ecs-node-cluster", "../ecs-cluster", "../alb", "../alb-api"]
}

inputs = {
  # General
  appname = local.appname
  env                = local.env
  tags               = local.tags

  # ECS Global
  ecs_cms_cluster_id            = dependency.ecs_cms_cluster.outputs.ecs_cluster_id
  ecs_node_cluster_id           = dependency.ecs_cluster.outputs.ecs_cluster_id
  ecs_lb_target_group_arn   = dependency.alb.outputs.alb_target_group_arns[0]
  ecs_internal_lb_target_group_arn = dependency.alb-api.outputs.alb_target_group_arns[0]
  ecs_service_desired_count = 1
  ecs_api_service_desired_count = 1
  ecs_vpc_id                = dependency.vpc.outputs.vpc_id

  # Fargate
  ecs_fargate_cpu    = 512
  ecs_fargate_memory = 1024

  ecs_fargate_api_cpu = 256
  ecs_fargate_api_memory = 512

  # ECS Service Deployment Configuration
  ecs_deployment_max_percent         = 200
  ecs_deployment_min_healthy_percent = 100

  # SG & Subnets
  ecs_service_private_subnets = dependency.vpc.outputs.private_subnets
  alb_security_group_id       = dependency.alb.outputs.alb_security_group_id
  alb_internal_security_group_id       = dependency.alb-api.outputs.alb_security_group_id
  
  # Container
  ecs_exec_role_arn               = dependency.iam-ecs.outputs.standalone_roles_arn["${local.project}-${local.appname}-ecs-execution-api-role-${local.env}"]
  ecs_task_role_arn               = dependency.iam-ecs.outputs.standalone_roles_arn["${local.project}-${local.appname}-ecs-api-role-${local.env}"]
  ecs_cms_exec_role_arn           = dependency.iam-ecs.outputs.standalone_roles_arn["${local.project}-${local.appname}-ecs-execution-cms-role-${local.env}"]
  ecs_cms_task_role_arn           = dependency.iam-ecs.outputs.standalone_roles_arn["${local.project}-${local.appname}-ecs-cms-role-${local.env}"]
  account_id                      = local.account_id

  ecs_task_definition = [
    {
      name      = "${local.project}-${local.appname}-cms-${local.env}"
      image     = local.ecs_service_api_container_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name = "DB_PASSWORD"
          value = "oaDxeZjB9mMELFGY"
        },
        {
          name = "DB_HOST"
          value = "snapshot-web-db-dev.c9i4ckaw0vhq.ap-southeast-1.rds.amazonaws.com"
        },
        {
          name = "DB_USER"
          value = "root"
        },
        {
          name = "DB_NAME"
          value = "snapshot"
        },
        {
          name = "DB_PORT"
          value = "3306"
        },
        {
          name = "CLOUD_FRONT_URL"
          value = "https://d1dzrudixdf39f.cloudfront.net/"
        },
        {  
          name = "APP_API_KEY"
          value = "54ed7ed33c211c016831269a3535899b"
        },
        {  
          name = "BASE_PATH"
          value = "https://dev-cms.snapshot-albbmq2.com/"
        },
        {  
          name = "APP_FRONT_URL"
          value = "https://dev.snapshot-albbmq2.com"
        },
        {  
          name = "APP_CLIENT_SECRET"
          value = "7f348c4c2b0faf8fec538d7611a9a780ec564a9605c85a0137dc9884eee329ed"
        },
        {  
          name = "APP_CLIENT_ID"
          value = "e07df902-619a-4f73-9560-5807fdbc3337"
        },
        {  
          name = "APP_PUBLIC_KEY"
          value = "SQ6KHrJJ5uV4H4a7e90qShW99YPoihXzsvOIm/OJZqg="
        },
        {  
          name = "APP_PRIVATE_KEY"
          value = "xOC+fIkrADSo3g5ASuBHKYOyITcWu0jT2EsCsLfN2KhJDooesknm5Xgfhrt73SpKFb31g+iKFfOy84ib84lmqA=="
        },
        {  
          name = "AWS_ACCESS_KEY_ID"
          value = ""
        },
        {  
          name = "AWS_SECRET_ACCESS_KEY"
          value = ""
        }

      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "${local.project}-${local.appname}-cms-${local.env}",
          "awslogs-region" : "ap-southeast-1",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "ecs-logs-${local.project}-${local.appname}-cms-${local.env}"
        }
      }
    }
  ]

  ecs_api_task_definition = [
    {
      name      = "${local.project}-${local.appname}-cms-${local.env}"
      image     = local.ecs_service_api_container_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name = "DB_PASSWORD"
          value = "oaDxeZjB9mMELFGY"
        },
        {
          name = "DB_HOST"
          value = "snapshot-web-db-dev.c9i4ckaw0vhq.ap-southeast-1.rds.amazonaws.com"
        },
        {
          name = "DB_USER"
          value = "root"
        },
        {
          name = "DB_NAME"
          value = "snapshot"
        },
        {
          name = "DB_PORT"
          value = "3306"
        },
        {
          name = "CLOUD_FRONT_URL"
          value = "https://d1dzrudixdf39f.cloudfront.net/"
        },
        {  
          name = "APP_API_KEY"
          value = "54ed7ed33c211c016831269a3535899b"
        },
        {  
          name = "BASE_PATH"
          value = "https://dev-api.snapshot-albbmq2.com/"
        },
        {  
          name = "APP_FRONT_URL"
          value = "https://dev.snapshot-albbmq2.com"
        },
        {  
          name = "APP_CLIENT_SECRET"
          value = "7f348c4c2b0faf8fec538d7611a9a780ec564a9605c85a0137dc9884eee329ed"
        },
        {  
          name = "APP_CLIENT_ID"
          value = "e07df902-619a-4f73-9560-5807fdbc3337"
        },
        {  
          name = "APP_PUBLIC_KEY"
          value = "SQ6KHrJJ5uV4H4a7e90qShW99YPoihXzsvOIm/OJZqg="
        },
        {  
          name = "APP_PRIVATE_KEY"
          value = "xOC+fIkrADSo3g5ASuBHKYOyITcWu0jT2EsCsLfN2KhJDooesknm5Xgfhrt73SpKFb31g+iKFfOy84ib84lmqA=="
        },
        {  
          name = "AWS_ACCESS_KEY_ID"
          value = ""
        },
        {  
          name = "AWS_SECRET_ACCESS_KEY"
          value = ""
        }

      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "${local.project}-${local.appname}-cms-${local.env}",
          "awslogs-region" : "ap-southeast-1",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "ecs-logs-${local.project}-${local.appname}-cms-${local.env}"
        }
      }
    }
  ]

}
