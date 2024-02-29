
resource "digitalocean_domain" "shopnest_dot_uz" {
  name       = var.domain_name
}


#<<Cert-Manager>>
resource "helm_release" "cert-manager" {
  depends_on = [ digitalocean_kubernetes_cluster.quantum_k8s_cluster ]
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  namespace = "cert-manager"
  create_namespace = true
  version = "1.8.0"

  set {
    name = "installCRDs"
    value = true
  }
}

#<<Ingress>>
resource "helm_release" "nginx_ingress" {
  depends_on = [ digitalocean_kubernetes_cluster.quantum_k8s_cluster ]
  name = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  set {
    name = "controller.publishService.enabled"
    value = true
  }
}

data "kubernetes_service_v1" "ingress_svc" {
  depends_on = [ helm_release.nginx_ingress ]
  metadata {
    name = var.nginx_svc_name
  }
}


#<<Domain-record>>
resource "digitalocean_record" "main_record" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "@"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "main_record_www" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "www"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "grafana" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "grafana"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "ezzydocs" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "ezzydocs"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "argocd" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "argocd"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "elasticsearch" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "elasticsearch"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "logstash" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "logstash"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_record" "kibana" {
  depends_on = [ data.kubernetes_service_v1.ingress_svc ]
  domain = digitalocean_domain.shopnest_dot_uz.id
  type   = "A"
  name   = "kibana"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}



resource "kubernetes_manifest" "letsencrypt_prod" {
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata   = {
      name = "letsencrypt-prod"
    }

    spec = {
      acme = {
        server  = "https://acme-v02.api.letsencrypt.org/directory"
        email   = "ismoillmirabbosoff@gmail.com"
        privateKeySecretRef = {
          name  = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [
    helm_release.nginx_ingress,
    helm_release.cert-manager,
  ]
}
