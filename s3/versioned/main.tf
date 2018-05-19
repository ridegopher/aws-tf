provider "aws" {
  region = "${var.region}"
}

variable "bucket_name" {
  description = "The name of the bucket"
}

variable "region" {
  description = "The region for the source s3 bucket"
  default = "us-east-1"
}

variable "versioning" {
  default = true
}

resource "aws_s3_bucket" "source" {
  provider = "aws"
  bucket = "${var.bucket_name}"
  region = "${var.region}"
  versioning {
    enabled = "${var.versioning}"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Created by github.com/aws-tf/s3/versioned module"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.source.arn}",
      "${aws_s3_bucket.source.arn}/*"
    ]
    principals {
      type = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = "${var.bucket_name}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.source.arn}"
}

output "bucket_domain_name" {
  value = "${aws_s3_bucket.source.bucket_domain_name}"
}

output "origin_access_identity" {
  value = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
}

