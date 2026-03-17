output "bucket" {
    value = aws_s3_bucket.tf_state.bucket
  
}
output "dynamodb_table" {
    value = aws_dynamodb_table.lock.name
  
}