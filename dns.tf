data "aws_route53_zone" "parent" {
  name = "andromeda.land."
}

resource "aws_acm_certificate" "parent" {
  domain_name       = "*.${data.aws_route53_zone.parent.name}"
  validation_method = "DNS"
  tags              = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "parent_validation" {
  for_each = {
    for dvo in aws_acm_certificate.parent.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.parent.zone_id
}

resource "aws_acm_certificate_validation" "parent" {
  certificate_arn         = aws_acm_certificate.parent.arn
  validation_record_fqdns = [for record in aws_route53_record.parent_validation : record.fqdn]
}

resource "aws_route53_zone" "prod" {
  provider = aws.prod
  name     = "prod.andromeda.land."
  tags     = local.tags
}

resource "aws_acm_certificate" "prod" {
  provider          = aws.prod
  domain_name       = "*.${aws_route53_zone.prod.name}"
  validation_method = "DNS"
  tags              = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "prod_validation" {
  provider = aws.prod
  for_each = {
    for dvo in aws_acm_certificate.prod.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.prod.zone_id
}

resource "aws_acm_certificate_validation" "prod" {
  provider                = aws.prod
  certificate_arn         = aws_acm_certificate.prod.arn
  validation_record_fqdns = [for record in aws_route53_record.prod_validation : record.fqdn]
}

resource "aws_route53_record" "prod_ns" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = aws_route53_zone.prod.name
  type    = "NS"
  ttl     = 300
  records = [
    aws_route53_zone.prod.name_servers[0],
    aws_route53_zone.prod.name_servers[1],
    aws_route53_zone.prod.name_servers[2],
    aws_route53_zone.prod.name_servers[3],
  ]
}

resource "aws_route53_zone" "staging" {
  provider = aws.staging
  name     = "staging.andromeda.land."
  tags     = local.tags
}

resource "aws_acm_certificate" "staging" {
  provider          = aws.staging
  domain_name       = "*.${aws_route53_zone.staging.name}"
  validation_method = "DNS"
  tags              = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "staging_validation" {
  provider = aws.staging
  for_each = {
    for dvo in aws_acm_certificate.staging.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.staging.zone_id
}

resource "aws_acm_certificate_validation" "staging" {
  provider                = aws.staging
  certificate_arn         = aws_acm_certificate.staging.arn
  validation_record_fqdns = [for record in aws_route53_record.staging_validation : record.fqdn]
}

resource "aws_route53_record" "staging_ns" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = aws_route53_zone.staging.name
  type    = "NS"
  ttl     = 300
  records = [
    aws_route53_zone.staging.name_servers[0],
    aws_route53_zone.staging.name_servers[1],
    aws_route53_zone.staging.name_servers[2],
    aws_route53_zone.staging.name_servers[3],
  ]
}