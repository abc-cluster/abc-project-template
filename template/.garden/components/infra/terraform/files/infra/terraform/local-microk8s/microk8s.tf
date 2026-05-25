terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "minio" {
  name = "minio/minio:latest"
}

resource "docker_container" "minio" {
  image = docker_image.minio.latest
  name  = "minio"
  ports {
    internal = 9000
    external = 9000
  }
  ports {
    internal = 9001
    external = 9001
  }
  env = [
    "MINIO_ROOT_USER=minioadmin",
    "MINIO_ROOT_PASSWORD=minioadmin"
  ]
  command = ["server", "/data", "--console-address", ":9001"]
}

resource "null_resource" "microk8s" {
  provisioner "local-exec" {
    command = <<-EOT
      if ! snap list | grep -q microk8s; then
        sudo snap install microk8s --classic
      fi
      sudo usermod -a -G microk8s $USER
      sudo chown -f -R $USER ~/.kube
      microk8s status --wait-ready
      microk8s enable dns storage ingress
    EOT
  }
}
