variable "alb_name" {
  type        = string
  description = "Name of the ALB"
}

variable "sg_name" {
  type        = string
  description = "Name of the SG of the ALB"
}

variable "project" {
  type        = string
  description = "project name"
}

variable "appname" {
  type        = string
  description = "appname name"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "public_subnets" {
  type        = list(any)
  description = "Public subnet id list"
}
variable "healthcheck_path" {
  type        = string
  description = "Healthcheck path"
}

variable "tags" {
  type        = map(any)
  description = "Common tags"
}

variable "alb_acm_certificate_arn" {
  type        = string
  description = "ALB certificate arn"
}

variable "tg_name" {
  type        = string
  description = "Target group name prefix"
}

variable "route53_record_name" {
  type        = string
  description = "ALB record name"
}

variable "route53_public_host_id" {
  type        = string
  description = "Public host ID"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "backend_port" {
  type = number
  description = "the backend port"
}

variable "whitelisted_ip_list" {
  type = list(string)
  description = "List of whitelisted IP to access to the ALB"
}

