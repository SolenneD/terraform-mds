terraform {
  backend "s3" {
    bucket     = "solenne-terraform"
    encrypt    = true
    key        = "live/eu-west-1/database/terraform.state"
    region     = "eu-west-1"
    secret_key = "[SECRET_KEY]"
    access_key = "[ACCESS_KEY]"
  }
}
