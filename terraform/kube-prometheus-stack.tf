resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = var.kubernetes_prometheus_namespace
  }
}

resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus-stack"
  namespace  = var.kubernetes_prometheus_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "../monitoring/kube-prometheus-stack/"
  depends_on = [kubernetes_namespace.prometheus]
}


resource "kubernetes_ingress_v1" "prometheus_ingress" {
  metadata {
    name      = "prometheus-ingress"
    namespace = "grafana"

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/backend-protocol"       = "HTTP"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout"  = "300"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
      "kubernetes.io/ingress.class"                        = "nginx"
      "cert-manager.io/cluster-issuer"                     = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "grafana.shopnest.uz"

      http {
        path {
          path = "/"
          backend {
            service {
              name = "kube-prometheus-stack-grafana"
              port {
                number = 80
              }
            }
          }

        }
      }
    }

    tls {
      hosts      = ["grafana.shopnest.uz"]
      secret_name = "letsencrypt-prod"
    }
  }
}