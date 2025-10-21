# terraform.tfvars

# The unique name for the S3 bucket. Must be globally unique across AWS.
bucket_name = "static-website-prod-2025-22020106"

# The AWS region where resources (S3, CloudFront API) will be deployed.
# CloudFront is a global service, but the distribution resource is managed in a region (usually us-east-1).
region = "us-east-1"

# The default file to serve when a user visits the root URL (e.g., https://example.com/)
root_object = "index.html"