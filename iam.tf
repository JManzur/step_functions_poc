data "aws_iam_policy_document" "lambda_policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "lambda_role_source" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_sf_poc_policy"
  path        = "/"
  description = "Place Holder"
  policy      = data.aws_iam_policy_document.lambda_policy_source.json
  tags        = { Name = "${var.name-prefix}-lambda-policy" }
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_sf_poc_policy_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_source.json
  tags               = { Name = "${var.name-prefix}-lambda-role" }
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

/* Step Function IAM */

data "aws_iam_policy_document" "sf_policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sf_role_source" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.us-east-1.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "sf_policy" {
  name        = "sf_poc_policy"
  path        = "/"
  description = "Place Holder"
  policy      = data.aws_iam_policy_document.sf_policy_source.json
  tags        = { Name = "${var.name-prefix}-sf-policy" }
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "sf_role" {
  name               = "sf_poc_policy_role"
  assume_role_policy = data.aws_iam_policy_document.sf_role_source.json
  tags               = { Name = "${var.name-prefix}-sf-role" }
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "sf_attach" {
  role       = aws_iam_role.sf_role.name
  policy_arn = aws_iam_policy.sf_policy.arn
}


/* API Gateway IAM Role*/

data "aws_iam_policy_document" "api_policy_source" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SFFullAccess"
    effect = "Allow"
    actions = [
      "states:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "api_role_source" {
  statement {
    sid    = "APIGWAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "api_policy" {
  name        = "api_poc_policy"
  path        = "/"
  description = "Place Holder"
  policy      = data.aws_iam_policy_document.api_policy_source.json
  tags        = { Name = "${var.name-prefix}-api-policy" }
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "api_role" {
  name               = "api_poc_policy_role"
  assume_role_policy = data.aws_iam_policy_document.api_role_source.json
  tags               = { Name = "${var.name-prefix}-api-role" }
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "api_attach" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_policy.arn
}