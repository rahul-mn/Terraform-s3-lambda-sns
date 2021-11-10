#Display these values as Output

output "s3_bucket_id" {
    value = aws_s3_bucket.lambda_bucket.id
}
output "s3_bucket_arn" {
    value = aws_s3_bucket.lambda_bucket.arn
}

output "sns_subscribed_email-id" {
  value = "${var.endpoint}"
}

output "sns_topic_arn" {
  value = aws_sns_topic.lambda_sns_topic.arn
}