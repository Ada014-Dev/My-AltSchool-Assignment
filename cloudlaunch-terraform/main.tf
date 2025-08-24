# -------------------------------
# S3 Buckets for CloudLaunch
# -------------------------------
provider "aws" {
  region  = "us-east-1"
  profile = "admin"
}


# 1. Public Website Bucket
resource "aws_s3_bucket" "cloudlaunch_site" {
  bucket = "cloudlaunch-site-bucket-adadev-014"

  tags = {
    Name = "CloudLaunch Site Bucket"
    Project = "CloudLaunch"
  }
}
# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "cloudlaunch_site" {
  bucket = aws_s3_bucket.cloudlaunch_site.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "error.html"
  }
}

# Allow public read access for website
resource "aws_s3_bucket_public_access_block" "cloudlaunch_site" {
  bucket = aws_s3_bucket.cloudlaunch_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Make it public (⚠️ Required for static site hosting)
resource "aws_s3_bucket_policy" "cloudlaunch_site_policy" {
  bucket = aws_s3_bucket.cloudlaunch_site.id
  depends_on = [aws_s3_bucket_public_access_block.cloudlaunch_site]
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.cloudlaunch_site.arn}/*"
      }
    ]
  })
}

# 2. Private Bucket
resource "aws_s3_bucket" "cloudlaunch_private" {
  bucket = "cloudlaunch-private-bucket-adadev-014"
  
  tags = {
    Name = "CloudLaunch Private Bucket"
    Project = "CloudLaunch"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "cloudlaunch_private" {
  bucket                  = aws_s3_bucket.cloudlaunch_private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Visible-Only Bucket
resource "aws_s3_bucket" "cloudlaunch_visible_only" {
  bucket = "cloudlaunch-visible-only-bucket-adadev-014"
  
  tags = {
    Name    = "CloudLaunch Visible Only Bucket"
    Project = "CloudLaunch"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "cloudlaunch_visible_only" {
  bucket                  = aws_s3_bucket.cloudlaunch_visible_only.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}