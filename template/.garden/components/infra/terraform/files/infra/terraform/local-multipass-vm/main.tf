terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

variable "vm_name" {
  description = "Name for the multipass VM"
  type        = string
  default     = "tf-multipass-vm"
}

variable "cloud_init_file" {
  description = "Path to the cloud-init file"
  type        = string
  default     = "cloud-init.yaml"
}

variable "cpus" {
  description = "Number of CPUs"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory (MB or GB, e.g., 2G)"
  type        = string
  default     = "2G"
}

variable "disk" {
  description = "Disk size (GB, e.g., 10G)"
  type        = string
  default     = "10G"
}

data "local_file" "cloud_init" {
  filename = var.cloud_init_file
}

resource "null_resource" "multipass_launch" {
  provisioner "local-exec" {
    command = <<-EOT
      multipass launch \
        --name ${var.vm_name} \
        --cpus ${var.cpus} \
        --mem ${var.memory} \
        --disk ${var.disk} \
        --cloud-init ${var.cloud_init_file}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = "${timestamp()}"
    cloud_init = data.local_file.cloud_init.content
  }
}

output "multipass_vm_name" {
  value = var.vm_name
}
