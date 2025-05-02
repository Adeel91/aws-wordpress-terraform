output "bucket_name" {
  value = aws_s3_bucket.static_website.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.static_website.arn
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.static_website.website_endpoint
}