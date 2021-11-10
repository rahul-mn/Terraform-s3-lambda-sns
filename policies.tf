#Creating Lambda role for S3 - LambdatoS3Role
resource "aws_iam_role" "Lambda_s3_sns_policy" {
  name = "Lambda_s3_sns_policy"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#Generating policy for LambdatoS3Role

resource "aws_iam_role_policy" "lambda_policy" {
  name = "Lambda_s3_sns_policy"
  role = aws_iam_role.Lambda_s3_sns_policy.id
    
    policy  = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowGetObject",
          "Action": [
            "s3:GetObject"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.id}/*"
        },
        {
          "Sid": "AllowSNSActions",
          "Action": [
            "sns:Publish",
            "sns:Subscribe"
          ],
          "Effect": "Allow",
          "Resource": "${aws_sns_topic.lambda_sns_topic.arn}"
        },
        {
          "Sid": "AllowCloudwatchlogCreat",
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
        "Resource": "${aws_lambda_function.putobject_triggerfunction.arn}"
        }
      ]
    }
  )
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.lambda_sns_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account-id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.lambda_sns_topic.arn,
    ]

    sid = "__default_statement_ID"
  }
}
