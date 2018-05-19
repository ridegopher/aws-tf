
module "test" {
  source = "../"
  domain = "ridegopher.com"
  bucket_name = "ridegopher-cdn"
  cnames = ["ridegopher.com", "www.ridegopher.com"]
}
