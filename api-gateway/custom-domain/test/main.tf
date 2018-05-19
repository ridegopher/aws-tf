variable "domain" {
  default = "ridegopher.com"
}

module "test" {
  source = "../"
  tld_domain = "ridegopher.com"
  sub_domain = "custom-sub-domain"
}
