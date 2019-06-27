data "archive_file" "contact-form" {
  type        = "zip"
  source_dir  = "../src/"
  output_path = "../index.zip"
}

data "template_file" "contact-form" {
  template = "contact-form-${var.env}-${var.aws_region}"
}

resource "aws_lambda_function" "contact-form" {
  function_name = "${data.template_file.contact-form.rendered}"
  filename      = "${data.archive_file.contact-form.output_path}"
  runtime       = "nodejs8.10"
  role          = "${aws_iam_role.contact-form.arn}"
  handler       = "index.handler"
  timeout       = 10

  environment {
    variables = {
      "NODE_ENV" = "production"
    }
  }
}

resource "aws_iam_role" "contact-form" {
  name               = "${data.template_file.contact-form.rendered}"
  assume_role_policy = "${data.aws_iam_policy_document.contact-form-assume-role.json}"
}

data "aws_iam_policy_document" "contact-form-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com", "lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "contact-form" {
  name        = "${aws_lambda_function.contact-form.function_name}"
  description = "basic cloudwatch logging permissions"

  policy = "${data.aws_iam_policy_document.contact-form.json}"
}

data "aws_iam_policy_document" "contact-form" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "SpecificTableDynamoDb"

    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem",
    ]

    effect    = "Allow"
    resources = ["${aws_dynamodb_table.contact-form.arn}"]
  }
}

resource "aws_iam_policy_attachment" "contact-form" {
  name       = "${aws_lambda_function.contact-form.function_name}"
  roles      = ["${aws_iam_role.contact-form.id}"]
  policy_arn = "${aws_iam_policy.contact-form.arn}"
}

resource "aws_cloudwatch_log_group" "contact-form" {
  name = "/aws/lambda/${aws_lambda_function.contact-form.function_name}"
}
