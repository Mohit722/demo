
provider "aws" {
  region = "ap-south-1"
}

variable "repo_names" {
  type = list
  default = ["wezvabaseimage", "wezvawebapp"]
}

resource "aws_ecr_repository" "example" {
  count = length(var.repo_names)
  name = var.repo_names[count.index]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true   
  }
}
