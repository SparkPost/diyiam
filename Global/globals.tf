# Global variables which will be used in multiple modules

variable "aws_profile" {
  description = "The Aws profile to use"
}

variable "aws_region" {
  description = "The Aws region to use"
  default     = "us-west-2"
}

variable "aws_short_region" {
  description = "The short name for an AWS region"
  default = {
    us-west-2 = "usw2"
    eu-west-1 = "euw1"
    us-east-1 = "use1"
  }
}

variable "short_az" {
  description = "The short az name from availability_zone or availability_zone_id"
  default = {
    us-west-2a = "usw2a"
    us-west-2b = "usw2b"
    us-west-2c = "usw2c"
    us-west-2d = "usw2d"
    eu-west-1a = "euw1a"
    eu-west-1b = "euw1b"
    eu-west-1c = "euw1c"
    usw2-az1   = "usw2a",
    usw2-az2   = "usw2b",
    usw2-az3   = "usw2c",
    usw2-az4   = "usw2d",
    euw1-az1   = "euw1a",
    euw1-az2   = "euw1b",
    euw1-az3   = "euw1c"
  }
}

