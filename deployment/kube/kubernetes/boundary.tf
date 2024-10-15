# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "kubernetes_deployment" "boundary" {
  metadata {
    name = "boundary"
    labels = {
      app = "boundary"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "boundary"
      }
    }

    template {
      metadata {
        labels = {
          app     = "boundary"
          service = "boundary"
        }
      }

      spec {
        volume {
          name = "boundary-config"

          config_map {
            name = "boundary-config"
          }
        }

        init_container {
          name  = "boundary-init"
          image = "hashicorp/boundary:latest"
          args = [
            "database",
            "init",
            "-config",
            "/boundary/boundary.hcl"
          ]

          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true

          }

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres:5432/boundary?sslmode=disable"
          }

          env {
            name  = "HOSTNAME"
            value = "boundary"
          }
        }

        container {
          image = "hashicorp/boundary:latest"
          name  = "boundary"

          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true
          }

          args = [
            "server",
            "-config",
            "/boundary/boundary.hcl"
          ]

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres:5432/boundary?sslmode=disable"
          }

          env {
            name  = "HOSTNAME"
            value = "boundary"
          }

          port {
            container_port = 9200
          }
          port {
            container_port = 9201
          }
          port {
            container_port = 9202
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9200
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 9200
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "boundary_controller" {
  metadata {
    name = "boundary-controller"
    labels = {
      app = "boundary-controller"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "boundary"
    }

    port {
      name        = "api"
      port        = 9200
      target_port = 9200
    }
    port {
      name        = "cluster"
      port        = 9201
      target_port = 9201
    }
    port {
      name        = "data"
      port        = 9202
      target_port = 9202
    }
  }
}

resource "kubernetes_ingress" "boundary_controller_ingress" {
  metadata {
    name = "boundary-controller-ingress"
    labels = {
      app = "boundary-controller"
    }
  }

  spec {
    rule {
      host = "api.boundary-example.com"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.boundary_controller.metadata[0].name
            service_port = "api" # Refers to the 9200 port in service
          }
        }
      }
    }

    rule {
      host = "cluster.boundary-example.com"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.boundary_controller.metadata[0].name
            service_port = "cluster" # Refers to the 9201 port in service
          }
        }
      }
    }

    # tls {
    #   hosts      = ["api.boundary-example.com", "cluster.boundary-example.com"]
    #   secret_name = "boundary-tls-secret"
    # }
  }
}

resource "kubernetes_service" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }

  spec {
    type = "LoadBalancer"
    selector = {
      app = "nginx-ingress"
    }

    port {
      port        = 80
      target_port = 80
    }

    port {
      port        = 443
      target_port = 443
    }
  }
}
