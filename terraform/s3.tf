# S3 Bucket for file storage
resource "aws_s3_bucket" "eira_storage" {
  bucket = "${local.name}-storage-${random_id.bucket_suffix.hex}"

  tags = local.tags
}

# Random ID for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "eira_storage" {
  bucket = aws_s3_bucket.eira_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "eira_storage" {
  bucket = aws_s3_bucket.eira_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "eira_storage" {
  bucket = aws_s3_bucket.eira_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "eira_storage" {
  bucket = aws_s3_bucket.eira_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 Bucket Policy for application access
resource "aws_s3_bucket_policy" "eira_storage" {
  bucket = aws_s3_bucket.eira_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSNodeGroupAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.node.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.eira_storage.arn}/*"
      },
      {
        Sid    = "AllowEKSNodeGroupListBucket"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.node.arn
        }
        Action = "s3:ListBucket"
        Resource = aws_s3_bucket.eira_storage.arn
      }
    ]
  })
}
