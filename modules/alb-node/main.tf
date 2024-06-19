module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.sg_name
  description = "Security group for example usage with ALB"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name               = var.alb_name
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets
  security_groups    = [module.alb_security_group.security_group_id]

  # http_tcp_listeners = [
  #   {
  #     port        = 80
  #     protocol    = "HTTP"
  #     action_type = "forward"
  #     target_group_index = 0
  #   }
  # ]
  http_tcp_listeners = [
     {
       port        = 80
       protocol    = "HTTP"
       action_type = "redirect"
       redirect = {
         port        = "443"
         protocol    = "HTTPS"
         status_code = "HTTP_301"
       }
     }
   ]

## uncomment this when you have the certificate created by acm
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.alb_acm_certificate_arn
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = var.tg_name
      backend_protocol = "HTTP"
      backend_port     = var.backend_port
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 60
        path                = var.healthcheck_path
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]
  tags = var.tags
}

## uncomment this when you have the certificate created by acm
resource "aws_route53_record" "www" {
  zone_id = var.route53_public_host_id
  name    = var.route53_record_name
  type    = "CNAME"
  ttl     = 50
  records = [module.alb.lb_dns_name]
  
}


