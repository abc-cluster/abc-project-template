provider "local" {}

resource "null_resource" "install_nomad_docker" {
  provisioner "local-exec" {
    command = <<-EOT
      #!/usr/bin/env bash
      # Install Docker
      if ! command -v docker >/dev/null 2>&1; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
      fi

      sudo usermod -aG docker $USER

      # Install Nomad
      if ! command -v nomad >/dev/null 2>&1; then
        NOMAD_VERSION=1.7.4
        wget https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
        unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
        sudo install nomad /usr/local/bin/
        rm nomad nomad_${NOMAD_VERSION}_linux_amd64.zip
      fi

      # Create a minimal Nomad config for Docker
      sudo mkdir -p /etc/nomad.d
      cat <<EOF | sudo tee /etc/nomad.d/nomad.hcl
      data_dir  = "/opt/nomad"
      bind_addr = "0.0.0.0"

      client {
        enabled = true
        host_network = "default"
        docker {
          enabled = true
        }
      }
      EOF

      sudo systemctl restart docker || true
      sudo nomad agent -config=/etc/nomad.d/nomad.hcl > /tmp/nomad.log 2>&1 &
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
