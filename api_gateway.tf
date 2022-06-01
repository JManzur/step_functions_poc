# Capture the AWS Account ID:
data "aws_caller_identity" "current" {}

# API Gateway definition:
resource "aws_api_gateway_rest_api" "sf" {
  name        = "SFGateway"
  description = "Step Function API Gateway"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

# ---------------------------------------------------
# API Resources definition:
# ---------------------------------------------------

# /create Resource
resource "aws_api_gateway_resource" "StartExecution" {
  rest_api_id = aws_api_gateway_rest_api.sf.id
  parent_id   = aws_api_gateway_rest_api.sf.root_resource_id
  path_part   = "StartExecution"
}

# API Model Schema definition:
resource "aws_api_gateway_model" "json_schema" {
  rest_api_id  = aws_api_gateway_rest_api.sf.id
  name         = "passthrough"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = file("templates/passthrough.template")
}

# ---------------------------------------------------
# POST Method:
# ---------------------------------------------------

# POST Request method:
resource "aws_api_gateway_method" "post" {
  rest_api_id      = aws_api_gateway_rest_api.sf.id
  resource_id      = aws_api_gateway_resource.StartExecution.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

  request_models = {
    "application/json" = aws_api_gateway_model.json_schema.name
  }
}

# POST Request integration:
resource "aws_api_gateway_integration" "integration-post" {
  credentials             = aws_iam_role.api_role.arn
  rest_api_id             = aws_api_gateway_rest_api.sf.id
  resource_id             = aws_api_gateway_resource.StartExecution.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  uri                     = "arn:aws:apigateway:${var.aws_region}:states:action/StartExecution"

  request_templates = {
    "application/json" = "${file("templates/request_template.template")}"
  }
}

# POST Method Response
resource "aws_api_gateway_method_response" "post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.sf.id
  resource_id = aws_api_gateway_resource.StartExecution.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# POST Integration Response
resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.sf.id
  resource_id = aws_api_gateway_resource.StartExecution.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_response_200.status_code

  response_templates = {
    "application/json" = "${file("templates/sf-response.template")}"
  }

  depends_on = [
    aws_api_gateway_integration.integration-post
  ]
}

# ---------------------------------------------------
# Stages, API-Key and Usage Plan
# ---------------------------------------------------

# Stage PROD definition:
resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.sf.id
  rest_api_id   = aws_api_gateway_rest_api.sf.id
  stage_name    = "v1"
}

# API-Key generation: 
resource "aws_api_gateway_api_key" "sf" {
  name        = "sf_api_key"
  description = "Step Function API API-Key"
  enabled     = true
  tags        = { Name = "${var.name-prefix}-api-key" }
}

# Usage plan definition:
resource "aws_api_gateway_usage_plan" "sf" {
  name = "sf_api_usage_plan"
  tags = { Name = "${var.name-prefix}-usage_plan" }

  api_stages {
    api_id = aws_api_gateway_rest_api.sf.id
    stage  = aws_api_gateway_stage.v1.stage_name
  }
}

# Declare the API key in the usage plan:
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.sf.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.sf.id
}

# ---------------------------------------------------
# Deploy the API
# ---------------------------------------------------
resource "aws_api_gateway_deployment" "sf" {
  rest_api_id = aws_api_gateway_rest_api.sf.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.sf.id,
      aws_api_gateway_method.post.id,
      aws_api_gateway_integration.integration-post.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_method.post,
    aws_api_gateway_integration.integration-post,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------
# Printing the outputs:
# ---------------------------------------------------
output "complete_invoke_url" {
  value = [
    "${aws_api_gateway_deployment.sf.invoke_url}${aws_api_gateway_stage.v1.stage_name}/${aws_api_gateway_resource.StartExecution.path_part}"
  ]
  description = "API Gateway Invoke URL"
}

# Use the "-raw" command to view the API key: "terraform output -raw api_key"
output "api_key" {
  value       = aws_api_gateway_api_key.sf.value
  sensitive   = true
  description = "API-Key"
}