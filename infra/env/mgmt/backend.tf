terraform {
  backend "s3" {
    bucket       = "ksbucket178"
    key          = "ksd-mgmt/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
#backend configs