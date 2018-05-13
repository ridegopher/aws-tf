variable "bucket_name" {
  description = "The name of the source bucket"
}

# END REQUIRED FIELDS

provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias  = "replica"
  region = "${var.replica_region}"
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
  name = "s3-replication-role-${var.bucket_name}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3_replication" {
  name = "s3-replication-policy-${var.bucket_name}"
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
  name = "s3-replication-policy-attachment-${var.bucket_name}"
  roles = ["${aws_iam_role.s3_replication.name}"]
  policy_arn = "${aws_iam_policy.s3_replication.arn}"
}

resource "aws_s3_bucket" "destination" {
  provider = "aws.replica"
  bucket = "${var.bucket_name}${var.replica_postfix}"
  region = "${var.replica_region}"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "source" {
  provider = "aws"
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
