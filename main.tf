terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.27"
    }
  }

  required_version = ">=0.14.9"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-9o83cupv8n"

  # When a resource has *prevent_destroy* set to true, Terraform will exit with an error if any effort is made to 
  # delete it (for example, by running terraform destruction). An critical resource, like this S3 bucket, which will 
  # house all of your Terraform state, could be accidentally deleted if you don't want it to. Of course, you can just 
  # comment that setting out if you absolutely want to eliminate it. 

  lifecycle {
    prevent_destroy = true
  }
}

# Set up the S3 bucket with versioning enabled so that each update to a file in the bucket results in a new version 
# of the file. This gives you the option to view earlier versions of the file and go back to them whenever you want, 
# which can be a helpful fallback option in case something goes wrong.

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# For all data written to this S3 bucket, server-side encryption can be enabled by default using the aws s3 
# bucket server side encryption configuration resource. Using S3 storage, this guarantees that your state files 
# and any secrets they might hold are always encrypted on disk:

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# To prevent any public access to the S3 bucket, use the aws s3 bucket public access block resource. It's worth 
# adding this extra degree of security since your Terraform state files can include confidential information, 
# thus nobody on your team should ever unintentionally make this S3 bucket public:

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a DynamoDB table with the primary key LockID to be used with Terraform as a locking mechanism.

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-9o83cupv8n"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# These variables will output the names of your DynamoDB table and your S3 bucket's Amazon Resource Name (ARN).

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
