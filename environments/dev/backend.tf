terraform {
  backend "s3" {
    bucket         = "anusha-tf-state-2024"
    key            = "contact-api/dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}