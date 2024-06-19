resource "aws_ecs_service" "cms" {
  name            = "${var.project}-${var.appname}-ecs-service-api-${var.env}"
  cluster         = var.ecs_node_cluster_id
  task_definition = aws_ecs_task_definition.serviceapi.arn
  desired_count   = var.ecs_api_service_desired_count

  launch_type           = "FARGATE"
  force_new_deployment  = true
  wait_for_steady_state = false

  deployment_maximum_percent         = var.ecs_deployment_max_percent
  deployment_minimum_healthy_percent = var.ecs_deployment_min_healthy_percent


  network_configuration {
    security_groups  = [aws_security_group.ecs_internal_task_sg.id]
    subnets          = var.ecs_service_private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ecs_internal_lb_target_group_arn
    container_name   = "${var.project}-${var.appname}-cms-${var.env}"
    container_port   = 80
  }

  health_check_grace_period_seconds = 300 # container readiness
  tags                              = var.tags
}

resource "aws_security_group" "ecs_internal_task_sg" {
  name        = "${var.project}-${var.appname}-ecs-internal-task-sg-${var.env}"
  description = "ECS task security group for ${var.project} ${var.appname} API"
  vpc_id      = var.ecs_vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_internal_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "ingress_internal_rds_rules" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ecs_internal_task_sg.id
}