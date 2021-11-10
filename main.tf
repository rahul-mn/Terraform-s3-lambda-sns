resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.bucket_prefix}-lambda-functions"
  acl    = "private"

  versioning {
      enabled = false
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/lambda_function.py"
  output_path = "${path.module}/python/lambda_function.py.zip"
}

resource "aws_lambda_function" "putobject_triggerfunction" {
  filename      = data.archive_file.lambda.output_path
  function_name = "putobject_trigger_function"
  role          = aws_iam_role.Lambda_s3_sns_policy.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      Scope = "SNS_Topic_Triggering"
    }
  }
}

resource "aws_sns_topic" "lambda_sns_topic" {
  name = "lambda_sns_topic-policy"
}


resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.lambda_sns_topic.arn
  protocol  = "email"
  endpoint  = "${var.endpoint}"
}

resource "aws_lambda_permission" "source_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.putobject_triggerfunction.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.putobject_triggerfunction.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.putobject_triggerfunction.arn
    events              = ["s3:ObjectCreated:*"]
#    filter_prefix       = "AWSLogs/"
#    filter_suffix       = ".log"
  }
  depends_on = [
    aws_lambda_permission.allow_bucket,
  ]
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.putobject_triggerfunction.function_name

  destination_config {
    on_success {
      destination = aws_sns_topic.lambda_sns_topic.arn
    }
  }
}