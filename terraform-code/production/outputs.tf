terraform {
  backend "s3" {
    bucket  = "valuentainment-terraform-state"
    key     = "terraform-state"
    region  = "us-east-2"
    encrypt = true
  }
}
