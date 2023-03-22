provider "aws" {
  region = var.region
  profile = "bc-demo"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  profile = "bc-demo"
}