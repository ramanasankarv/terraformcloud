## Introduction
Terraform + Terragrunt template for a Nextjs & Drupal ECS (with Fargate) task with Cloudfront, RDS & Opensearch.

## Version of Terragrunt and Terraform tested
- terraform v1.0.11
- terragrunt v0.40.2

## Current status of the project
Warning, it's a very first draft of a template.
It creates:
- VPC
- VPC Endpoint (to ensure S3 direct access)
- IAM roles and policies (iam-common) to create an infrastructure deployer and an application deployer for the CI/CD (Ekino Gitlab)
- ECS Cluster
- Cloudfront (must be configured) + WAF to whitelist IP (only for dev & uat)
- ALB to load balance ecs task + WAF to whitelist IP (only for dev & uat)
- RDS (to be created) for the Database
- OPENSEARCH (to be created) for the Open Search
- ECS Service to deploy the task 
