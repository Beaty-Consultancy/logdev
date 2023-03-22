resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "client" {
  zone_id = aws_route53_zone.zone.id
  name    = "client.${aws_route53_zone.zone.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.zone.id
  name    = "api.${aws_route53_zone.zone.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.zone.id
  name    = aws_route53_zone.zone.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}