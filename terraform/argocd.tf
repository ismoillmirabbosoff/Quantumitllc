# # <<ArgoCD>>
# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = var.kubernetes_argocd_namespace
#   }
# }


# resource "helm_release" "argocd" {
#   depends_on = [ kubernetes_namespace.argocd ]
#   name = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = var.kubernetes_argocd_namespace
#   create_namespace = true
#   version          = "3.35.4"
# }

# resource "kubernetes_ingress_v1" "argocd_ingress" {
#   metadata {
#     name      = "argocd-ingress"
#     namespace = "argocd"

#     annotations = {
#       "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
#       "nginx.ingress.kubernetes.io/backend-protocol"       = "HTTPS"
#       "nginx.ingress.kubernetes.io/proxy-connect-timeout"  = "300"
#       "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
#       "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
#       "nginx.ingress.kubernetes.io/ssl-passthrough"        = "true"
#       "kubernetes.io/ingress.class"                        = "nginx"
#       "cert-manager.io/cluster-issuer"                     = "letsencrypt-prod"
#     }
#   }

#   spec {
#     ingress_class_name = "nginx"

#     rule {
#       host = "argocd.shopnest.uz"

#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = "argocd-server"
#               port {
#                 number = 80
#               }
#             }
#           }

#         }
#       }
#     }

#     tls {
#       hosts      = ["argocd.shopnest.uz"]
#       secret_name = "letsencrypt-prod"
#     }
#   }
# }


# resource "null_resource" "password" {
#   provisioner "local-exec" {
#     working_dir = "./"
#     command     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
#   }
# }

# resource "null_resource" "del-argo-pass" {
#   depends_on = [null_resource.password]
#   provisioner "local-exec" {
#     command = "kubectl -n argocd delete secret argocd-initial-admin-secret"
#   }
# }
