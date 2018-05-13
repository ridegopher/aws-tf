## Cross-Region Replication S3 Bucket Module

https://docs.aws.amazon.com/AmazonS3/latest/dev/crr.html


This module will create buckets with cross-region replication set up for you.

Usage:
```
module "s3_for_cdn" {
  source = "github.com/ridegopher/aws-tf//s3/replicated"

  // Optional Fields

  /*
  * If bucket_name is omitted, it will auto-generate names:
  * s3-replication-<AWS_ACCOUNT_ID>
  * s3-replication-<AWS_ACCOUNT_ID>-replica
  */
  bucket_name = "ridegopher-cdn"
  region = "us-west-2"
  ...
}

output "arn" {
  value = "${module.s3_replicated_test.arn}"
}

output "replica_arn" {
  value = "${module.s3_replicated_test.replica_arn}"
}

```