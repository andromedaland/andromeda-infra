data "aws_route53_zone" "parent" {
  name = "andromeda.land."
}

resource "aws_route53_zone" "staging" {
  provider = aws.staging
  name     = "staging.andromeda.land."
  tags     = local.tags
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