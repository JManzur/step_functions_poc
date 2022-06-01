resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "poc-state-machine"
  role_arn = aws_iam_role.sf_role.arn

  tags = { Name = "${var.name-prefix}-state-machine" }

  definition = <<EOF
{
"Comment": "AWS Step Functions POC",
"StartAt": "WhichLambda",
"States": {
    "WhichLambda": {
    "Type": "Choice",
    "Choices": [
        {
        "Variable": "$.go_to",
        "StringEquals": "lambda01",
        "Next": "lambda01"
        },
        {
        "Variable": "$.go_to",
        "StringEquals": "lambda02",
        "Next": "lambda02"
        }
    ]
    },
    "lambda01": {
    "Type": "Task",
    "Resource": "${aws_lambda_function.lambda_01.arn}",
    "End": true,
    "ResultSelector": {
        "body.$": "$.Payload.body"
    }
    },
    "lambda02": {
    "Type": "Task",
    "Resource": "${aws_lambda_function.lambda_02.arn}",
    "End": true,
    "ResultSelector": {
        "body.$": "$.Payload.body"
    }
    }
}
}
EOF
}