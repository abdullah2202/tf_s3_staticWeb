# 🚀 Static Website Deployment: AWS S3, CloudFront, Terraform & GitHub Actions

This project demonstrates a fully automated, production-ready pipeline for deploying a static website to Amazon Web Services (AWS) using **Infrastructure as Code (IaC)** with **Terraform** and **Continuous Deployment (CD)** with **GitHub Actions**.

## 🏗️ Architecture

The infrastructure is provisioned using Terraform and follows modern security best practices:

1.  **Amazon S3:** Stores the static website files privately.
2.  **AWS CloudFront (CDN):** Serves as the Content Delivery Network, providing a global edge network for low-latency delivery, caching, and **HTTPS/SSL**.
3.  **Origin Access Control (OAC):** Ensures the S3 bucket is only accessible via the specified CloudFront distribution, keeping the content secure and non-public.
4.  **GitHub Actions:** Automates two key processes:
    * **IaC Pipeline:** Runs `terraform apply` to provision or update the AWS infrastructure.
    * **CD Pipeline:** Syncs local website files to S3 and invalidates the CloudFront cache upon every push to the `main` branch.



## 🛠️ Prerequisites

Before deploying, you must have the following:

1.  **AWS Account:** With credentials configured.
2.  **GitHub Repository:** This repository (where the code lives).
3.  **AWS Credentials in GitHub Secrets:**
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`
    * `AWS_REGION` (e.g., `us-east-1`)
    * `S3_BUCKET_NAME` (Must match the `var.bucket_name` in `variables.tf`)
    * `CLOUDFRONT_DISTRIBUTION_ID` (Retrieved after the first Terraform apply)

## 💻 Deployment Steps

### 1. Provision Infrastructure (Terraform)

The **`terraform`** job in the GitHub Action workflow handles this automatically on push.

* **Files:** Located in the `terraform/` directory.
* **Resources:** S3 Bucket, S3 Bucket Policy (OAC access), CloudFront Distribution, and OAC.

### 2. Deploy Content (CI/CD)

The **`deploy_content`** job automatically handles deployment after the infrastructure is ready.

1.  **Sync:** Copies the contents of the local `website/` directory to the S3 bucket using `aws s3 sync --delete`.
2.  **Cache Invalidation:** Issues a command to CloudFront to invalidate the cache (`--paths "/*"`), forcing all edge locations to pull the new content from S3, ensuring users see the updated website immediately.

## 🔗 Accessing the Website

Once the CI/CD pipeline completes successfully, your website will be accessible via the CloudFront Domain Name.

Find the domain name in the AWS console or look at the outputs from the Terraform job in the GitHub Actions run history:

**CloudFront URL Example:** `https://d12345abcdefgh.cloudfront.net`