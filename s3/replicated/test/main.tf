
module "s3_replicated_test" {
  source = "../"
}

output "arn" {
  value = "${module.s3_replicated_test.arn}"
}

output "replica_arn" {
  value = "${module.s3_replicated_test.replica_arn}"
}