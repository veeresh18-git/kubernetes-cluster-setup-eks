terraform {
  backend "s3" {
    bucket       = "ksbucket178"
    key          = "dvs/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
    #    profile        =  "ksd"
  }
}
#backend configs
#AWS_SECRET_ACCESS_KEY = "AKIA_TEST_SECRET_123456"
#aws secret

