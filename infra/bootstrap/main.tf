provider "aws" {
  region = var.aws_region
  profile = "ksd"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
  tags = {
    Name = "tfstate"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled" 
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = { 
    Name = "tf-locks" 
}
}

#team collabration
#avoid concurrent changes
#state lock and versioning
#Remote state is mandatory for team collaboration and safe locking. 
#S3 versioning = rollbacks; DynamoDB = lock to avoid concurrent writes.