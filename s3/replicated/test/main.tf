
module "state" {
  source = "../../../.common/state"
}

module "s3_replicated_test" {
  source = "../"
  bucket_name = "s3-replicated-test-${module.state.account_id}"
}