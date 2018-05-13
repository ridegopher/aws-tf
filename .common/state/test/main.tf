module "state_test" {
  source = "../../state"
}

output "hosted_zone" {
  value = "${module.state_test.hosted_zone}"
}

output "hosted_zone_id" {
  value = "${module.state_test.hosted_zone_id}"
}

output "domain" {
  value = "${module.state_test.domain}"
}

output "region" {
  value = "${module.state_test.region}"
}

output "certificate_arn" {
  value = "${module.state_test.certificate_arn}"
}

output "account_id" {
  value = "${module.state_test.account_id}"
}

output "caller_arn" {
  value = "${module.state_test.caller_arn}"
}

output "caller_user" {
  value = "${module.state_test.caller_user}"
}

output "ecr_url" {
  value = "${module.state_test.ecr_url}"
}