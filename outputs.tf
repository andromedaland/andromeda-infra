output "state_bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.state.name
}