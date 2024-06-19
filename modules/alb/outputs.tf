output "alb_arn" {
  value = module.alb.lb_arn
}

output "alb_target_group_arns" {
  value = module.alb.target_group_arns
}

output "alb_security_group_id" {
  value = module.alb_security_group.security_group_id
}

output "alb_security_group_arn" {
  value = module.alb_security_group.security_group_arn
}




