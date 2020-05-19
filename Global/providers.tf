provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "<ALIAS HERE>"
  region  = var.aws_region
  profile = "<AWS PROFILE>"
}
