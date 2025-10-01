terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.83.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.3"
    }
  }
  required_version = ">= 1.0.0"
}

provider "ibm" {
  # Configuration options
  # API key is expected to be set via environment variable: IC_API_KEY
  region = var.region
}