terraform {
  backend "s3" {
    bucket       = "anusha-tf-state-2024"
    key          = "contact-api/prod/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}