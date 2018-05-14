provider "aws" {
  region = "${var.region}"
}

variable "region" {
  default = "us-east-1"
}

variable "domain" {
  description = "The TLD for the custom domain"
}

variable "sub_domain" {
  description = "the sub domain portion"
}

variable "zone_id" {
  description = "The zone id for the hosted zone"
}

variable "cert_arn" {
  description = "The certificate arn for SSL"
  default = ""
}

locals {
  full_domain = "${var.sub_domain}.${var.domain}"
  hosted_zone = "/hostedzone/${var.zone_id}"
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name = "${local.full_domain}"
  certificate_arn = "${var.cert_arn}"
}

resource "aws_route53_record" "route53" {
  zone_id = "/hostedzone/${var.zone_id}"
  name = "${local.full_domain}"
  type = "A"
  alias {
    name = "${aws_api_gateway_domain_name.domain.cloudfront_domain_name}"
    zone_id = "${aws_api_gateway_domain_name.domain.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}