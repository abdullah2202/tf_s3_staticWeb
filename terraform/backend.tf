# backend.tf

terraform {
  backend "s3" {
    bucket = "project-tf-state-22020106"      # The name of the S3 bucket created in Step A
    key    = "static-site/terraform.tfstate" # The path and filename for your state file
    region = "us-east-1"                     # Your AWS region
    
    encrypt        = true                    # Encrypt the state file
  }
}