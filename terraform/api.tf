resource "aws_api_gateway_rest_api" "contact-form" {
  name = "contact-form"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "contact-form" {
  depends_on = [
    "aws_api_gateway_method.contact-form",
    "aws_api_gateway_integration.contact-form",
  ]

  stage_name  = "contact-form-${var.env}"
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
}

resource "aws_lambda_permission" "contact-form" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.contact-form.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.contact-form.id}/*/${aws_api_gateway_method.contact-form.http_method}${aws_api_gateway_resource.contact-form.path}"
}

resource "aws_api_gateway_resource" "contact-form" {
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
  parent_id   = "${aws_api_gateway_rest_api.contact-form.root_resource_id}"
  path_part   = "contact"
}

resource "aws_api_gateway_method" "contact-form" {
  rest_api_id      = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id      = "${aws_api_gateway_resource.contact-form.id}"
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "contact-form-options" {
  rest_api_id      = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id      = "${aws_api_gateway_resource.contact-form.id}"
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method_response" "contact-form" {
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id = "${aws_api_gateway_resource.contact-form.id}"
  http_method = "${aws_api_gateway_method.contact-form.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "contact-form-options" {
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id = "${aws_api_gateway_resource.contact-form.id}"
  http_method = "${aws_api_gateway_method.contact-form-options.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "contact-form" {
  rest_api_id             = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id             = "${aws_api_gateway_resource.contact-form.id}"
  http_method             = "${aws_api_gateway_method.contact-form.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.contact-form.arn}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "contact-form-options" {
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id = "${aws_api_gateway_resource.contact-form.id}"
  http_method = "${aws_api_gateway_method.contact-form-options.http_method}"
  type        = "MOCK"
}

resource "aws_api_gateway_integration_response" "contact-form" {
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id = "${aws_api_gateway_resource.contact-form.id}"
  http_method = "${aws_api_gateway_method.contact-form.http_method}"
  status_code = "${aws_api_gateway_method_response.contact-form.status_code}"
  depends_on  = ["aws_api_gateway_integration.contact-form"]

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration_response" "contact-form-options" {
  rest_api_id = "${aws_api_gateway_rest_api.contact-form.id}"
  resource_id = "${aws_api_gateway_resource.contact-form.id}"
  http_method = "${aws_api_gateway_method.contact-form-options.http_method}"
  status_code = "${aws_api_gateway_method_response.contact-form-options.status_code}"
  depends_on  = ["aws_api_gateway_integration.contact-form-options"]

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
