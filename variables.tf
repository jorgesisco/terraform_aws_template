variable "ENV" {
  default = "dev"
}

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "REGION" {}
variable "AVAILABILITY_ZONE" {}
variable "AVAILABILITY_ZONE_ID" {}

variable "VPC" {}
variable "INSTANCE_SUBNET" {}
variable "INSTANCE_NAME" {}
variable "INSTANCE_TYPE" {}

variable "UNTAGGED_IMAGES" {
  default = 3
}

variable "REPO_LIST" {
  description = "List of ECR repositories to be created"
  type = list(string)
  default = ["etl-emails-base", "etl-emails-worker", "etl-emails-web"]
}
