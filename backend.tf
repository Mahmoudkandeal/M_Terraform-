terraform {
  backend "s3" {
    bucket = "my-tf-state-project-abdallah-bucket"
    key    = "tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock-state-table"
  }
}
