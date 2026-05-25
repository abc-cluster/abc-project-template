terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.24.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.20.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "vault" {
  address = "http://127.0.0.1:8200"
}

provider "consul" {
  address = "127.0.0.1:8500"
}

resource "vault_mount" "kvv2" {
  path = "secret"
  type = "kv-v2"
}

resource "vault_kv_secret_v2" "example" {
  mount = vault_mount.kvv2.path
  name  = "app/config"
  data_json = jsonencode({
    api_key = "example-api-key"
    db_url  = "postgres://user:pass@localhost:5432/db"
  })
}

resource "consul_key_prefix" "config" {
  path_prefix = "app/"
  subkeys = {
    "feature_flag" = "true"
    "max_connections" = "100"
  }
}
