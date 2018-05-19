provider "aws" {
  region = "${var.region}"
}

variable "tld_domain" {
  description = "The TLD"
}

variable "wildcard_acm_cert_arn" {
  description = "HTTPS only!"
  default = ""
}

variable "bucket_name" {
  description = "The name of the origin bucket. Will default to domain"
  default = ""
}

variable "lambda_function_name" {
  default = "edge-spa"
}

variable "cnames" {
  type = "list"
  default = []
}

variable "region" {
  default = "us-east-1"
}

variable "custom_error_response_page_path" {
  default = "/index.html"
}

data "aws_acm_certificate" "certificate" {
  domain = "${var.tld_domain}"
  most_recent = true
  types = ["AMAZON_ISSUED"]
}

data "aws_lambda_function" "edge" {
  function_name = "${var.lambda_function_name}"
}

data "aws_route53_zone" "zone" {
  name = "${var.tld_domain}."
}

locals {
  bucket_name = "${var.bucket_name == "" ? var.tld_domain : var.bucket_name}"
  wildcard_acm_cert_arn = "${var.wildcard_acm_cert_arn == "" ? data.aws_acm_certificate.certificate.arn : var.wildcard_acm_cert_arn}"
  rewrite_lambda_arn = "${data.aws_lambda_function.edge.qualified_arn}"
  hosted_zone = "/hostedzone/${data.aws_route53_zone.zone.zone_id}"
}

module "s3_bucket" {
  source = "../s3/versioned"
  bucket_name = "${local.bucket_name}"
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true
  http_version = "http2"
  price_class = "PriceClass_100"
  default_root_object = "index.html"
  is_ipv6_enabled = true
  aliases = "${var.cnames}"
  origin {
    origin_id = "s3-origin-bucket"
    domain_name = "${module.s3_bucket.bucket_domain_name}"
    s3_origin_config {
      origin_access_identity = "${module.s3_bucket.origin_access_identity}"
    }
  }

  default_cache_behavior {
    target_origin_id = "s3-origin-bucket"
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
    compress = true
    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${local.rewrite_lambda_arn}"
    }
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${local.wildcard_acm_cert_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  custom_error_response {
    error_caching_min_ttl = 3000
    error_code = 404
    response_code = 200
    response_page_path = "${var.custom_error_response_page_path}"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "top_domain" {
  count   = "${length(var.cnames)}"
  zone_id = "${local.hosted_zone}"
  name    = "${element(var.cnames, count.index)}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "bucket_name" {
  value = "${local.bucket_name}"
}

