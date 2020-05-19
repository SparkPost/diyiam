terraform {
  backend "s3" {
    bucket         = "<BUCKET NAME>"
    dynamodb_table = "<DYNAMOTABLE>"
    key            = "<KEYNAME>/terraform.tfstate"
    region         = "<REGION>"
    encrypt        = true
    profile        = "<AWS PROFILE>"
  }
}
