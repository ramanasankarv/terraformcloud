variable "bucketname" {
  description = "The name of Bucket name"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "project"
  type        = string
  default     = null 
}

variable "env" {
  description = "Environment"
  type        = string
  default     = null
}
