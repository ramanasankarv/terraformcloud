variable "bastion_ami_id" {
  description = "AMI ID of the bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type of the bastion host"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Subnet ID of the bastion host"
  type        = string
}


variable "bastion_vpc_id" {
  description = "VPC ID of the bastion host"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "appname" {
  description = "Application name"
  type        = string
}
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "project" {
  type        = string
  description = "project name"
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to update the SSM agent on"
  type        = list(string)
  default     = ["i-005c8dc33739d5233"] # Example instance IDs
}