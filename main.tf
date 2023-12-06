/*
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_12345"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#compress/zip .py file to upload into lambda
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "delete_txt_files.py"
  output_path = "delete_txt_files.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "delete_txt_files"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "delete_txt_files.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      S3_BUCKET_NAME = "my-bucket-909090"
    }
  }
}
*/
resource "aws_instance" "example" {
  ami           = "ami-06d4b7182ac3480fa"
  instance_type = "t2.micro"
  tags = {
    Name = "example-instance"
  }
}
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "stop_instance.py"
  output_path = "stop_instance.zip"
}
resource "aws_lambda_function" "stop_instance" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "stop_instance"
  role             = aws_iam_role.lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  
}
resource "aws_iam_role" "lambda" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instance.arn
}
resource "aws_cloudwatch_event_rule" "stop_instance" {
  name                = "stop_instance"
  description         = "Stop EC2 instance every day after class"
  schedule_expression = "cron(0 15 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop_instance" {
  rule      = aws_cloudwatch_event_rule.stop_instance.name
  arn       = aws_lambda_function.stop_instance.arn
  target_id = "stop_instance"
}
