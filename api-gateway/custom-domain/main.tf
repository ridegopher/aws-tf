provider "aws" {
  region = "${var.region}"
}

variable "region" {
  default = "us-east-1"
}

variable "tld_domain" {
  description = "The TLD for the custom domain"
}

variable "sub_domain" {
  description = "the sub domain portion"
}

data "aws_route53_zone" "zone" {
  name = "${var.tld_domain}."
}

data "aws_acm_certificate" "cert" {
  domain = "${var.tld_domain}"
  most_recent = true
  types = ["AMAZON_ISSUED"]
}

locals {
  full_domain = "${var.sub_domain}.${var.tld_domain}"
  hosted_zone = "/hostedzone/${data.aws_route53_zone.zone.zone_id}"
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name = "${local.full_domain}"
  certificate_arn = "${data.aws_acm_certificate.cert.arn}"
}

resource "aws_route53_record" "route53" {
  zone_id = "${local.hosted_zone}"
  name = "${local.full_domain}"
  type = "A"
  alias {
    name = "${aws_api_gateway_domain_name.domain.cloudfront_domain_name}"
    zone_id = "${aws_api_gateway_domain_name.domain.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}