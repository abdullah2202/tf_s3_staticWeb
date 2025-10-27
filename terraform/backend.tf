terraform {
  backend "s3" {
    bucket = "project-tf-state-22020106"        # S3 bucket where the state file is stored
    key    = "static-site/terraform.tfstate"  
    region = "us-east-1"                      
    encrypt        = true                     
  }
}