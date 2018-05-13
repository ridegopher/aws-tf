## Replicated S3 Bucket Module

Usage:
```
module "s3_for_cdn" {
  source = "github.com/ridegopher/aws-tf//s3/replicated"
  bucket_name = "ridegopher-cdn"
}

output "arn" {
  value = "${module.s3_replicated_test.arn}"
}

output "replica_arn" {
  value = "${module.s3_replicated_test.replica_arn}"
}

```