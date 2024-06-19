variable "cluster_name" {
  type = string
}

variable "tags" {
  type        = map(any)
  description = "Common tags"
}
