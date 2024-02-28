terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "quantum_k8s_cluster" {
  name    = var.cluster_name
  region  = var.cluster_region
  version = var.cluster_version
  tags    = ["k8s"]

  node_pool {
    name       = "worker-node"
    size       = var.node_size
    auto_scale = true
    min_nodes = 1
    max_nodes = 3
  }
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.quantum_k8s_cluster.endpoint
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.cluster_ca_certificate)
  client_certificate = base64decode(digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.client_certificate)
  client_key = base64decode(digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.client_key)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = [
      "kubernetes",
      "cluster",
      "kubeconfig",
      "exec-credential",
      "--version=v1beta1",
      digitalocean_kubernetes_cluster.quantum_k8s_cluster.id
    ]
  }
}

provider "helm" {
  debug = true

  kubernetes {
    config_path            = "./kubeconfig"
    host                   = digitalocean_kubernetes_cluster.quantum_k8s_cluster.endpoint
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.cluster_ca_certificate)
    client_certificate = base64decode(digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.client_certificate)
    client_key = base64decode(digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.client_key)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "doctl"
      args = [
        "kubernetes",
        "cluster",
        "kubeconfig",
        "exec-credential",
        "--version=v1beta1",
        digitalocean_kubernetes_cluster.quantum_k8s_cluster.id
      ]
    }
  }
}


output "my-kubeconfig" {
  value     = digitalocean_kubernetes_cluster.quantum_k8s_cluster.kube_config.0.raw_config
  sensitive = true
}
