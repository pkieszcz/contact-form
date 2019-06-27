data "archive_file" "ddb-stream" {
  type        = "zip"
  source_dir  = "../src/ddb-stream"
  output_path = "../ddb-stream.zip"
}

data "template_file" "ddb-stream" {
  template = "ddb-stream-${var.env}-${var.aws_region}"
}

resource "aws_sns_topic" "ddb-stream" {
  name = "ddb-stream"
}

resource "aws_lambda_function" "ddb-stream" {
  function_name    = "${data.template_file.ddb-stream.rendered}"
  filename         = "${data.archive_file.ddb-stream.output_path}"
  source_code_hash = "${data.archive_file.ddb-stream.output_base64sha256}"
  publish          = true
  runtime          = "nodejs8.10"
  role             = "${aws_iam_role.ddb-stream.arn}"
  handler          = "index.handler"
  timeout          = 10

  environment {
    variables = {
      "NODE_ENV"      = "production"
      "SNS_TOPIC_ARN" = "${aws_sns_topic.ddb-stream.arn}"
    }
  }
}

resource "aws_iam_role" "ddb-stream" {
  name               = "${data.template_file.ddb-stream.rendered}"
  assume_role_policy = "${data.aws_iam_policy_document.ddb-stream-assume-role.json}"
}

data "aws_iam_policy_document" "ddb-stream-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ddb-stream" {
  name        = "${aws_lambda_function.ddb-stream.function_name}"
  description = "Permissions for dynamodb stream to sns lambda role"

  policy = "${data.aws_iam_policy_document.ddb-stream.json}"
}

data "aws_iam_policy_document" "ddb-stream" {
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
    actions = [
      "lambda:InvokeFunction",
    ]

    effect    = "Allow"
    resources = ["${aws_lambda_function.ddb-stream.arn}"]
  }

  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
    ]

    effect    = "Allow"
    resources = ["${aws_dynamodb_table.contact-form.arn}/stream/*"]
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "ddb-stream" {
  name       = "${aws_lambda_function.ddb-stream.function_name}"
  roles      = ["${aws_iam_role.ddb-stream.id}"]
  policy_arn = "${aws_iam_policy.ddb-stream.arn}"
}

resource "aws_cloudwatch_log_group" "ddb-stream" {
  name = "/aws/lambda/${aws_lambda_function.ddb-stream.function_name}"
}

resource "aws_lambda_event_source_mapping" "ddb-stream" {
  event_source_arn  = "${aws_dynamodb_table.contact-form.stream_arn}"
  function_name     = "${aws_lambda_function.ddb-stream.arn}"
  starting_position = "LATEST"
  batch_size        = 1
}
