resource "aws_ecs_task_definition" "service" {
  family = "${var.project}-${var.appname}-cms-service-${var.env}"
  container_definitions = jsonencode(var.ecs_task_definition)

  execution_role_arn       = var.ecs_cms_exec_role_arn
  task_role_arn            = var.ecs_cms_task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_fargate_cpu
  memory                   = var.ecs_fargate_memory

  tags = var.tags
}

resource "aws_ecs_task_definition" "serviceapi" {
  family = "${var.project}-${var.appname}-api-service-${var.env}"
  container_definitions = jsonencode(var.ecs_api_task_definition)

  execution_role_arn       = var.ecs_exec_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_fargate_api_cpu
  memory                   = var.ecs_fargate_api_memory

  tags = var.tags
}

