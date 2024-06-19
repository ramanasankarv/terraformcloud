variable "ecs_cms_cluster_id" {
  description = "The ECS cluster to deploy to"
  type        = string
}

variable "ecs_node_cluster_id" {
  description = "The ECS cluster to deploy to"
  type        = string
}

variable "ecs_lb_target_group_arn" {
  description = "The ARN of the target group to use for the ECS service"
  type        = string
}

variable "ecs_internal_lb_target_group_arn" {
  description = "The ARN of the target group to use for the ECS service"
  type        = string  
}
variable "ecs_deployment_max_percent" {
  description = "The maximum percent of the service to deploy at once"
  type        = number
}

variable "ecs_fargate_cpu" {
  description = "The CPU units to reserve for fargate"
  type        = number
}

variable "ecs_fargate_api_cpu" {
  description = "The CPU units to reserve for fargate"
  type        = number
}

variable "ecs_fargate_memory" {
  description = "The memory to reserve for fargate"
  type        = number
}

variable "ecs_fargate_api_memory" {
  description = "The memory to reserve for fargate"
  type        = number
}

variable "ecs_deployment_min_healthy_percent" {
  description = "The minimum percent of the service to keep healthy"
  type        = number
}

variable "ecs_service_private_subnets" {
  description = "The private subnets to use for the ECS service"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The security group used by the ALB"
  type        = string
}
variable "alb_internal_security_group_id" {
  description = "The security group used by the ALB"
  type        = string
}

variable "ecs_vpc_id" {
  description = "The VPC to use for the ECS service"
  type        = string
}

variable "ecs_service_desired_count" {
  description = "The desired count of the ECS service"
  type        = number
}

variable "ecs_api_service_desired_count" {
  description = "The desired count of the ECS api service"
  type        = number 
  default = 2
}

variable "ecs_exec_role_arn" {
  description = "The ARN of the ECS execution role to use"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role to use"
  type        = string
}

variable "ecs_cms_exec_role_arn" {
  description = "The ARN of the ECS execution role to use"
  type        = string
}

variable "ecs_cms_task_role_arn" {
  description = "The ARN of the ECS task role to use"
  type        = string
}

variable "appname" {
  type        = string
  description = "Name of the client tenant"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "env" {
  type        = string
  description = "environment to deploy to"
}

variable "project" {
  type        = string
  description = "project name"
}

variable "account_id" {
  type        = string
  description = "Accound ID"
}

variable "ecs_task_definition" {
  type = list(any)
  description = "The ECS taskdefinition"
}

variable "ecs_api_task_definition" {
  type = list(any)
  description = "The ECS taskdefinition"  
}
