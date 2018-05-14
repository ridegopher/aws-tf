variable "domain" {
  default = "ridegopher.com"
}

data "aws_route53_zone" "zone" {
  name = "${var.domain}."
}

data "aws_acm_certificate" "certificate" {
  domain = "${var.domain}"
  most_recent = true
  types = ["AMAZON_ISSUED"]
}

module "test" {
  source = "../"
  domain = "${var.domain}"
  sub_domain = "api"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  cert_arn = "${data.aws_acm_certificate.certificate.arn}"
}
