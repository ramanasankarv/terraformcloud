variable "opensearch_name" {
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

variable "tags" {
  type        = map(any)
  description = "Common tags"
}


variable "tg_name" {
  type        = string
  description = "Target group name prefix"
}

variable "env" {
  type        = string
  description = "Environment"
}


variable "whitelisted_ip_list" {
  type = list(string)
  description = "List of whitelisted IP to access to the ALB"
}

variable "random_password_length" {
  description = "Length of random password to create"
  type        = number
  default     = 16
}