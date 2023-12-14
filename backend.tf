terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }

  backend "remote" {
    organization = "aitne_consultoria"

    workspaces {
      name = "ELT-emails"
    }
  }
}