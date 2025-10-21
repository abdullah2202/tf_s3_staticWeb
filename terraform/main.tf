# main.tf - Static Website Infrastructure using S3 and CloudFront

# Configure the AWS Provider and specify the region using the variable
provider "aws" {
  region = var.region
}

# The S3 bucket where the static website files will be stored.
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name 
  
  # Ensures the bucket and its contents are deleted when running 'terraform destroy'.
  # WARNING: Use with caution in production environments!
  force_destroy = true 
  tags = {
    Name    = "StaticWebsiteBucket-${var.bucket_name}"
    Project = "Terraform-CI-CD-Static-Site"
  }
}

# Block all public access settings for the S3 bucket.
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Creates a new Origin Access Control (OAC). 
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "static-site-oac-v3"
  description                       = "OAC for S3 static site access via CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always" 
  signing_protocol                  = "sigv4"  
}


# Data source for generating the IAM policy document.
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"

    actions = [
      "s3:GetObject",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*", # Grant access to all objects in the bucket
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      # This condition restricts access ONLY to this specific CloudFront distribution
      values   = [aws_cloudfront_distribution.s3_distribution.arn] 
    }
  }
}

# Attaches the generated policy to the S3 bucket.
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
  # Explicit dependency needed because the policy needs the distribution's ARN.
  depends_on = [aws_cloudfront_distribution.s3_distribution] 
}


# NEW: Data Sources to look up the managed policies

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "s3_origin" {
  name = "Managed-AllViewerExceptHostHeader"
}

# Creates the CloudFront Distribution, which is the public-facing endpoint (CDN).
resource "aws_cloudfront_distribution" "s3_distribution" {
  
  # Defines the origin (source of content) as the private S3 bucket.
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.website_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.root_object 

  # Configuration for the default content serving behavior.
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"] 
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.id
    viewer_protocol_policy = "redirect-to-https" 
    
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id 
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.s3_origin.id
  }

  # Geographic restriction settings (none for unrestricted access).
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Viewer certificate setup.
  viewer_certificate {
    cloudfront_default_certificate = true 
  }
}