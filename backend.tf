terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "devops90-bucket"
    # access_key = "AKIATCOXT2D7DOJEFCND"
    # secret_key = "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"
  }
}
