variable "AWS_ACCESS_KEY_ID" {
}

variable "AWS_SECRET_ACCESS_KEY" {
}

variable "region" {
  type        = string
  description = "AWS region to host resources"
  default     = "eu-west-2"
}

variable "project" {
  type        = string
  description = "client project to enable naming of resources"
  default     = "demo"
}

variable "environment" {
  type        = string
  description = "Production / pre-production"
  default     = "development"
}

variable "domain" {
  type        = string
  description = "Public DNS"
  default     = "demo.beatyconsultancy.co.uk"
}

# CloudFront variables
variable "cf_price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_100"
}

variable "error_ttl" {
  description = "The minimum amount of time (in secs) that cloudfront caches an HTTP error code."
  default     = "30"
}