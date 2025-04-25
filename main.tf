terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

# Calling the environment module based 
module "environment" {
  # @todo: change this to dynamically selecting environment
  # based on the terraform workspace selected.
  source       = "./environments/staging"
  project_name = var.project_name
}