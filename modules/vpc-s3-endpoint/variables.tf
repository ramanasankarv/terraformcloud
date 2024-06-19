variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "route_table_ids" {
  description = "The route table IDs"
  type        = list(string)
}

variable "tags" {
  description = "The tags"
  type        = map(string)
}

