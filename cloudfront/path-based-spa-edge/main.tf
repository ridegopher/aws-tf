variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.region}"
}

locals {
  lambda_name = "path-based-spa-edge"
}

data "aws_iam_policy_document" "lambda" {
  provider = "aws"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

data "archive_file" "lambda" {
  type = "zip"
  output_path = "${path.module}/.zip/lambda.zip"
  source_dir = "${path.module}/lambda"
}

resource "aws_iam_role" "lambda" {
  provider = "aws"
  name = "${local.lambda_name}-role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_lambda_function" "lambda" {
  provider = "aws"
  function_name = "${local.lambda_name}"
  filename = "${data.archive_file.lambda.output_path}"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  role = "${aws_iam_role.lambda.arn}"
  runtime = "nodejs6.10"
  handler = "index.handler"
  memory_size = 128
  timeout = 3
  publish = true
}

output "arn" {
  value = "${aws_lambda_function.lambda.arn}"
}

output "version" {
  value = "${aws_lambda_function.lambda.version}"
}
