terraform {
  backend "s3" {
    bucket         = "serhii-terraform-state-lesson-5"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}