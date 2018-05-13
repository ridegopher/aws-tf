provider "aws" {
  region = "${var.region}"
}

variable "bucket_name" {
  description = "The name of the source bucket"
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

resource "aws_iam_role" "s3_replication" {
  name = "${var.bucket_name}-s3-replication-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_replication" {
  name = "${var.bucket_name}-s3-replication-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "s3_replication" {
  name = "${var.bucket_name}-s3-replication-policy-attachment"
  roles = ["${aws_iam_role.s3_replication.name}"]
  policy_arn = "${aws_iam_policy.s3_replication.arn}"
}

resource "aws_s3_bucket" "destination" {
  bucket = "${var.bucket_name}${var.replica_postfix}"
  region = "${var.replica_region}"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "source" {
  bucket = "${var.bucket_name}"
  region = "${var.region}"
  replication_configuration {
    role = "${aws_iam_role.s3_replication.arn}"
    rules {
      id = "replica"
      prefix = ""
      status = "Enabled"
      destination {
        bucket = "${aws_s3_bucket.destination.arn}"
        storage_class = "REDUCED_REDUNDANCY"
      }
    }
  }
  versioning {
    enabled = true
  }
}
