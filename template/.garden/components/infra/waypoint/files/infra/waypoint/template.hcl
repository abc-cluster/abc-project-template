project = "h2o-app"

app "h2o-api" {
  path = "app"

  build {
    use "docker" {}
    registry {
      # Optional: configure your Docker registry here
      # use "docker" {
      #   image = "yourrepo/h2o-api"
      #   tag = "latest"
      # }
    }
  }

  deploy {
    use "docker" {
      service_port = 8080
    }
  }

  release {
    use "docker" {}
  }
}
