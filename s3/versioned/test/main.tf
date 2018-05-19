
data "aws_caller_identity" "acct" {}

module "test" {
  source = "../"
  bucket_name = "test-s3-versionded-${data.aws_caller_identity.acct.account_id}"
}

output "orgin_identity" {
  value = "${module.test.origin_access_identity_arn}"
}