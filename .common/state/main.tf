// Start State Config

variable "top_level_domain" {
  description = "The TLD for the project"
  default = "ridegopher.com"
}

variable "region" {
  default = "us-east-1"
}

// End State Config

terraform {
  backend "s3" {
    bucket = "ops-config-mgmt"
    region = "us-east-1"
    key = "terraform-state/stack/state/terraform.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"
}

// TODO: Things to add. VPC, certs

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}

output "ecr_url" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/"
}


data "aws_route53_zone" "zone" {
  name = "${var.top_level_domain}."
}

output "hosted_zone" {
  value = "/hostedzone/${data.aws_route53_zone.zone.zone_id}"
}

output "hosted_zone_id" {
  value = "${data.aws_route53_zone.zone.id}"
}

output "domain" {
  value = "${var.top_level_domain}"
}

output "region" {
  value = "${var.region}"
}

data "aws_acm_certificate" "certificate" {
  domain = "${var.top_level_domain}"
  most_recent = true
  types = ["AMAZON_ISSUED"]
}

output "certificate_arn" {
  value = "${data.aws_acm_certificate.certificate.arn}"
}

