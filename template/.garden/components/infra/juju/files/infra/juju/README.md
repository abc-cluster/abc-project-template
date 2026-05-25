# Nomad + Docker Deployment with Juju and Terraform

## Terraform

- `nomad_docker.tf` provisions and configures Nomad and Docker on a local or cloud VM.

## Juju

- `nomad-docker-bundle.yaml` deploys the Nomad charm configured for Docker.
- Overlays (e.g., `development-overlay.yaml`) allow for easy customization.

## Usage

### Terraform

```bash
terraform init
terraform apply
```

### Juju

```bash
juju bootstrap localhost nomad-local
juju deploy ./nomad-docker-bundle.yaml --overlay overlays/development-overlay.yaml
juju status
```

## Further Customization

- Add jobspecs to run containers via Nomad/Docker.
- Adjust overlays for production (e.g., datacenter, networking, secrets).
- Integrate with Consul or Vault for service discovery and secrets management.
