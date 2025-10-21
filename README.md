# Static Website Deployment: AWS S3, CloudFront, Terraform & GitHub Actions

This project demonstrates a fully automated, production-ready pipeline for deploying a static website to Amazon Web Services (AWS) using **Infrastructure as Code (IaC)** with **Terraform** and **Continuous Deployment (CD)** with **GitHub Actions**.

## Architecture Overview

The infrastructure is provisioned using Terraform and follows modern security best practices:

| Component | Purpose | Security Note |
| :--- | :--- | :--- |
| **Amazon S3 (Content)** | Stores the static website files (HTML, CSS, JS, etc.). | **Kept Private** and inaccessible directly from the public internet. |
| **Amazon S3 (Backend State)** | A separate, versioned S3 bucket used to store the **`terraform.tfstate`** file. | **Crucial** for state consistency across all automated deployments. |
| **AWS CloudFront (CDN)** | Serves as the Content Delivery Network, providing low-latency delivery, caching, and **HTTPS/SSL**. | Publicly exposed endpoint for the website. |
| **Origin Access Control (OAC)** | Securely connects CloudFront to the private S3 bucket. | Enforces that only CloudFront can retrieve content from S3. |
| **GitHub Actions** | Automates both the infrastructure provisioning and the content deployment lifecycle. | Uses secure GitHub Secrets for AWS authentication. |



---

## Prerequisites

Before deploying, you must have the following items configured:

### 1. AWS Remote State Backend

You must set up a dedicated S3 bucket to store your Terraform state. This bucket must be created **manually** or outside of this project's Terraform code.

* **Create a Bucket:** Create a new S3 bucket (e.g., `my-project-tf-state-2025`).
* **Enable Versioning:** Ensure **Versioning** is enabled on this state bucket.
* **Update Configuration:** Verify your **`backend.tf`** file correctly references this new bucket.

### 2. GitHub Secrets

The following secrets must be configured in your GitHub repository (**Settings** > **Secrets** > **Actions**):

| Secret Name | Purpose | Value Source |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | IAM user Access Key ID for authentication. | AWS IAM Console |
| `AWS_SECRET_ACCESS_KEY` | IAM user Secret Access Key for authentication. | AWS IAM Console |
| `AWS_REGION` | The region where resources are deployed (e.g., `us-east-1`). | `terraform.tfvars` |
| `S3_BUCKET_NAME` | The **unique** name of the content bucket. | `terraform.tfvars` (`bucket_name`) |
| `CLOUDFRONT_DISTRIBUTION_ID` | The ID of the CDN used for cache invalidation. | **AWS Console / Terraform Output** (Add after the first successful deploy) |

---

## Deployment Workflow

The workflow is managed entirely by GitHub Actions, typically triggered by a push to the `main` branch.

### 1. Provision Infrastructure (Initial Run)

The first successful run of the workflow will:

* **Initialize:** Run `terraform init -reconfigure` to connect to the S3 backend and confirm the state.
* **Create:** Provision the S3 Bucket, CloudFront OAC, and CloudFront Distribution.
* **Complete:** The process usually takes **10–20 minutes** as AWS deploys the CloudFront distribution globally.

### 2. Subsequent Runs (Content Updates)

After the initial setup, every push to `main` will:

* **State Check:** The Terraform job will run, quickly checking the remote S3 state and finding **no changes** to the infrastructure.
* **Content Sync:** The deployment job runs `aws s3 sync` to upload only the new or modified files (e.g., your updated `index.html`) to the private S3 bucket.
* **Cache Invalidation:** The final step runs `aws cloudfront create-invalidation` to immediately clear the old content from the CDN, ensuring the new version is served to all users.

To update your website, simply modify files in the **`website/`** directory, commit, and push to `main`.

---

## Accessing the Website

Once the `terraform apply` step is complete, the website is live.

To find the URL:

1.  View the **Outputs** of the successful Terraform job in the GitHub Actions history.
2.  Alternatively, go to the **AWS CloudFront Console**, find the distribution, and copy the **Domain Name** (it will look like `https://d12345abcdefgh.cloudfront.net`).