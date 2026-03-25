variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "hello-world-aws"
}

variable "app_runner_service_name" {
  description = "Name of the App Runner service"
  type        = string
  default     = "svc-hwc-aws-aue-001"
}

variable "image_tag" {
  description = "Container image tag to deploy"
  type        = string
  default     = "latest"
}

variable "func_ecr_repo_name" {
  description = "Name of the ECR repository for Lambda functions"
  type        = string
  default     = "hello-world-aws-func"
}
