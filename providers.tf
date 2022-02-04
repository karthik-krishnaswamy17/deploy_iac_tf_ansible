terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">= 3.0.0"
  }
}
provider "aws" {
  profile = var.profile
  region  = var.region-master
  alias   = "region-master"
}
provider "aws" {
  profile = var.profile
  region  = var.region-worker
  alias   = "region-worker"
}