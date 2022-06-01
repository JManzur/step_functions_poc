# Zip the lambda code
data "archive_file" "lambda_01" {
  type        = "zip"
  source_dir  = "lambda_code/lambda_01/"
  output_path = "output_lambda_zip/lambda_01/lambda_01.zip"
}

# Create lambda function
resource "aws_lambda_function" "lambda_01" {
  filename      = data.archive_file.lambda_01.output_path
  function_name = "lambda_01"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main_handler.lambda_handler"
  description   = "place_holder"
  tags          = { Name = "${var.name-prefix}-lambda" }

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.lambda_01.output_path)

  runtime = "python3.9"
  timeout = "120"
}

data "archive_file" "lambda_02" {
  type        = "zip"
  source_dir  = "lambda_code/lambda_02/"
  output_path = "output_lambda_zip/lambda_02/lambda_02.zip"
}

# Create lambda function
resource "aws_lambda_function" "lambda_02" {
  filename      = data.archive_file.lambda_02.output_path
  function_name = "lambda_02"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main_handler.lambda_handler"
  description   = "place_holder"
  tags          = { Name = "${var.name-prefix}-lambda" }

  # Prevent lambda recreation
  source_code_hash = filebase64sha256(data.archive_file.lambda_02.output_path)

  runtime = "python3.9"
  timeout = "120"
}