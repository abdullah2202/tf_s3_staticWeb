# variables.tf

variable "bucket_name" {
  description = "The globally unique name for the S3 bucket."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1" # Often hardcoded, but good practice to define it here
}

variable "root_object" {
  description = "The default root object for the static site (e.g., index.html)."
  type        = string
  default     = "index.html"
}