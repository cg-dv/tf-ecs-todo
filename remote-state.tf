terraform {
  backend "s3" {
    bucket = "terraform-remote-state-bucket-123"
    key    = "tf-ecs-todo"
    region = "us-west-1"
  }
}
