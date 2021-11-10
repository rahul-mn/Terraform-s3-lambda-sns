variable "bucket_prefix" {
    description = "Prefix for the bucket name followed by adding “-lambda-functions” as suffix. "
    default     = "snslambda"
}

variable "endpoint" {
description = "Email address to subscribe to SNS"
default = "rahulmeena261@yahoo.com"
}

variable "account-id" {
  description = "AWS Account ID on which sns services are created "
  default = "856361924591"
}
