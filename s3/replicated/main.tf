variable "bucket_name" {
  description = "The name of the source bucket. If non is provided one will be generated"
  default = ""
}

variable "replica_postfix" {
  description = "This will be appended to the bucket_name for the replica bucket"
  default = "-replica"
}

variable "region" {
  description = "The region for the source s3 bucket"
  default = "us-east-1"
}

variable "replica_region" {
  description = "The region for the replcated s3 bucket"
  default = "us-west-1"
}

variable "storage_class" {
  default = "REDUCED_REDUNDANCY"
}

provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias  = "replica"
  region = "${var.replica_region}"
}

data "aws_caller_identity" "acct" {}

locals {
  bucket_name = "${var.bucket_name == "" ? "s3-replication-${data.aws_caller_identity.acct.account_id}" : var.bucket_name}"
}

data "aws_iam_policy_document" "s3_replication_role" {
  provider = "aws"
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_replication" {
  name = "s3-replication-role-${local.bucket_name}"
  assume_role_policy = "${data.aws_iam_policy_document.s3_replication_role.json}"
}

data "aws_iam_policy_document" "s3_replication_policy" {
  provider = "aws"
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.source.arn}"]
  }
  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.source.arn}/*"]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.replica.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_replication" {
  name = "s3-replication-policy-${local.bucket_name}"
  policy = "${data.aws_iam_policy_document.s3_replication_policy.json}"
}

resource "aws_iam_policy_attachment" "s3_replication" {
  name = "s3-replication-policy-attachment-${local.bucket_name}"
  roles = ["${aws_iam_role.s3_replication.name}"]
  policy_arn = "${aws_iam_policy.s3_replication.arn}"
}

resource "aws_s3_bucket" "replica" {
  provider = "aws.replica"
  bucket = "${local.bucket_name}${var.replica_postfix}"
  region = "${var.replica_region}"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "source" {
  provider = "aws"
  bucket = "${local.bucket_name}"
  region = "${var.region}"
  replication_configuration {
    role = "${aws_iam_role.s3_replication.arn}"
    rules {
      id = "replica"
      prefix = ""
      status = "Enabled"
      destination {
        bucket = "${aws_s3_bucket.replica.arn}"
        storage_class = "${var.storage_class}"
      }
    }
  }
  versioning {
    enabled = true
  }
}

output "arn" {
  value = "${aws_s3_bucket.source.arn}"
}

output "replica_arn" {
  value = "${aws_s3_bucket.replica.arn}"
}
