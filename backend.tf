terraform {
  required_version = ">=1.3.2"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Beaty-Consultancy"

    workspaces {
      name = "logdev"
    }
  }
}